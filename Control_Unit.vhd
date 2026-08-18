----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.05.2026 12:39:55
-- Design Name: 
-- Module Name: Control_Unit - Behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Control_Unit is
    Port ( 
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        Opcode      : in STD_LOGIC_VECTOR (3 downto 0);
        Z_Flag      : in STD_LOGIC;
        
        PC_Out      : out STD_LOGIC;
        Reg_Out     : out STD_LOGIC;
        MDR_Out     : out STD_LOGIC;
        ALU_Out     : out STD_LOGIC;
        IR_Out_Imm  : out STD_LOGIC;
        IR_Out_Addr : out STD_LOGIC;
        
        PC_In       : out STD_LOGIC;
        Reg_Write   : out STD_LOGIC;
        MAR_In      : out STD_LOGIC;
        MDR_In      : out STD_LOGIC;
        IR_In       : out STD_LOGIC;
        A_In        : out STD_LOGIC;
        B_In        : out STD_LOGIC;
        
        Mem_Read    : out STD_LOGIC;
        Mem_Write   : out STD_LOGIC;
        
        PC_Inc      : out STD_LOGIC;
        ALU_Op      : out STD_LOGIC_VECTOR (3 downto 0)
    );
end Control_Unit;

architecture Behavioral of Control_Unit is

-- הגדרת התחנות
    type state_type is (Fetch_T0, Fetch_T1, Fetch_T2, Decode, 
                        ALU_T3, ALU_T4, ALU_T5,
                        LOAD_T3, LOAD_T4, LOAD_T5,
                        STORE_T3, STORE_T4, STORE_T5,
                        LDI_T3, 
                        JMP_T3, 
                        JZ_T3,
                        HALT_T3);
                        
    signal Current_State, Next_State : state_type;

begin

    process(clk, reset)
    begin
        if reset = '1' then
            Current_State <= Fetch_T0;
        elsif rising_edge(clk) then
            Current_State <= Next_State;
        end if;
    end process;

-- התהליך 
    process(Current_State, Opcode, Z_Flag)
    begin
-- איפוס כל הרכיבים
        PC_Out      <= '0';
        Reg_Out     <= '0';
        MDR_Out     <= '0';
        ALU_Out     <= '0';
        IR_Out_Imm  <= '0';
        IR_Out_Addr <= '0';
        PC_In       <= '0';
        Reg_Write   <= '0';
        MAR_In      <= '0';
        MDR_In      <= '0';
        IR_In       <= '0';
        A_In        <= '0';
        B_In        <= '0';
        Mem_Read    <= '0';
        Mem_Write   <= '0';
        PC_Inc      <= '0';
        ALU_Op      <= Opcode;
        
        Next_State  <= Fetch_T0; -- ברירת מחדל

        case Current_State is
            
            -- ==========================================
            -- Fetch
            -- ==========================================
            when Fetch_T0 =>
                PC_Out <= '1';
                MAR_In <= '1';
                Next_State <= Fetch_T1;
                
            when Fetch_T1 =>
                Mem_Read <= '1';
                MDR_In <= '1';
                PC_Inc <= '1';
                Next_State <= Fetch_T2;
                
            when Fetch_T2 =>
                MDR_Out <= '1';
                IR_In <= '1';
                Next_State <= Decode;
                
            -- ==========================================
            -- Decode
            -- ==========================================
            when Decode =>
            -- ALU בין 0000 לבין 0101
                if Opcode = "0000" or Opcode = "0001" or Opcode = "0010" or 
                   Opcode = "0011" or Opcode = "0100" or Opcode = "0101" then 
                    Next_State <= ALU_T3;
                elsif Opcode = "1000" then 
                    Next_State <= LOAD_T3;
                elsif Opcode = "1001" then
                    Next_State <= STORE_T3;
                elsif Opcode = "1010" then 
                    Next_State <= LDI_T3;
                elsif Opcode = "1100" then 
                    Next_State <= JMP_T3;
                elsif Opcode = "1101" then 
                    Next_State <= JZ_T3;
                elsif Opcode = "1111" then -- פקודת העצירה
                    Next_State <= HALT_T3;
                else
                    Next_State <= Fetch_T0;
                end if;
                
            -- ==========================================
            -- ALU
            -- ==========================================
            when ALU_T3 =>
                Reg_Out <= '1';
                A_In <= '1';
                Next_State <= ALU_T4;
                
            when ALU_T4 =>
                Reg_Out <= '1';
                B_In <= '1';
                Next_State <= ALU_T5;
                
            when ALU_T5 =>
                ALU_Op <= Opcode; -- בתוך הALU ייקבע איזה פעולה לבצע , ושם היא תתבצע
                ALU_Out <= '1';
                Reg_Write <= '1';
                Next_State <= Fetch_T0;
                
            -- ==========================================
            -- LOAD
            -- ==========================================
            when LOAD_T3 =>
                Reg_Out <= '1';
                MAR_In <= '1';
                Next_State <= LOAD_T4;
                
            when LOAD_T4 =>
                Mem_Read <= '1';
                MDR_In <= '1';
                Next_State <= LOAD_T5;
                
            when LOAD_T5 =>
                MDR_Out <= '1';
                Reg_Write <= '1';
                Next_State <= Fetch_T0;
                
            -- ==========================================
            -- STORE
            -- ==========================================
            when STORE_T3 =>
                Reg_Out <= '1';
                MAR_In <= '1';
                Next_State <= STORE_T4;
                
            when STORE_T4 =>
                Reg_Out <= '1';
                MDR_In <= '1';
                Next_State <= STORE_T5;
                
            when STORE_T5 =>
                Mem_Write <= '1';
                Next_State <= Fetch_T0;
                
            -- ==========================================
            -- LDI פעולה מיידית
            -- ==========================================
            when LDI_T3 =>
                IR_Out_Imm <= '1';
                Reg_Write <= '1';
                Next_State <= Fetch_T0;
                
            -- ==========================================
            -- JMP פעולה מיידית
            -- ==========================================
            when JMP_T3 =>
                IR_Out_Addr <= '1';
                PC_In <= '1';
                Next_State <= Fetch_T0;
                
            -- ==========================================
            -- JZ פעולה מיידית
            -- ==========================================
            when JZ_T3 =>
                if Z_Flag = '1' then
                    IR_Out_Addr <= '1';
                    PC_In <= '1';
                end if;
                -- אם ה-Z הוא 0, הלוגיקה פשוט לא תדליק כלום, והפקודה תסתיים
                Next_State <= Fetch_T0;
            -- ==========================================
            -- HALT (עצירה מוחלטת)
            -- ==========================================
            when HALT_T3 =>
                Next_State <= HALT_T3;   
            -- ==========================================
            -- הגנת ברירת מחדל
            -- ==========================================
            when others =>
                Next_State <= Fetch_T0;
                
        end case;
    end process;

end Behavioral;