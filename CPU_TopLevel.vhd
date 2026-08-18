----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Module Name: CPU_TopLevel - Structural
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CPU_TopLevel is
    Port ( 
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        
        Mem_Addr     : out STD_LOGIC_VECTOR(15 downto 0);
        Mem_Data_In  : in  STD_LOGIC_VECTOR(15 downto 0);
        Mem_Data_Out : out STD_LOGIC_VECTOR(15 downto 0);
        Mem_Read_Pin : out STD_LOGIC;
        Mem_Write_Pin: out STD_LOGIC
    );
end CPU_TopLevel;

architecture Structural of CPU_TopLevel is

    -- ==========================================
    -- 1. Component Declarations (הצהרות תואמות 100%)
    -- ==========================================
    component PC_reg
        Port ( clk         : in STD_LOGIC;
               reset       : in STD_LOGIC;
               PC_In       : in STD_LOGIC;
               PC_Inc      : in STD_LOGIC;
               address_in  : in STD_LOGIC_VECTOR (15 downto 0);
               address_out : out STD_LOGIC_VECTOR (15 downto 0));
    end component;

    component Reg_16bit
        Port ( clk      : in STD_LOGIC;
               reset    : in STD_LOGIC;
               load     : in STD_LOGIC;
               data_in  : in STD_LOGIC_VECTOR (15 downto 0);
               data_out : out STD_LOGIC_VECTOR (15 downto 0));
    end component;

    component ALU
        Port ( A_in    : in STD_LOGIC_VECTOR (15 downto 0);
               B_in    : in STD_LOGIC_VECTOR (15 downto 0);
               ALU_Op  : in STD_LOGIC_VECTOR (3 downto 0);
               ALU_Out : out STD_LOGIC_VECTOR (15 downto 0);
               Z_Flag  : out STD_LOGIC);
    end component;

    component Register_File
        Port ( clk       : in STD_LOGIC;
               reset     : in STD_LOGIC;
               Reg_Write : in STD_LOGIC;
               Address   : in STD_LOGIC_VECTOR (3 downto 0);
               Data_In   : in STD_LOGIC_VECTOR (15 downto 0);
               Data_Out  : out STD_LOGIC_VECTOR (15 downto 0));
    end component;

    component Control_Unit
        Port ( clk         : in STD_LOGIC;
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
               ALU_Op      : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    -- ==========================================
    -- 2. Signals (חוטים פנימיים שרצים על לוח האם)
    -- ==========================================
    signal Data_Bus : STD_LOGIC_VECTOR(15 downto 0);
    
    signal PC_Out_Val   : STD_LOGIC_VECTOR(15 downto 0);
    signal Reg_Out_Val  : STD_LOGIC_VECTOR(15 downto 0);
    signal MDR_Out_Val  : STD_LOGIC_VECTOR(15 downto 0);
    signal ALU_Out_Val  : STD_LOGIC_VECTOR(15 downto 0);
    
    signal IR_Full_Val  : STD_LOGIC_VECTOR(15 downto 0);
    signal IR_Imm_Val   : STD_LOGIC_VECTOR(15 downto 0);
    signal IR_Addr_Val  : STD_LOGIC_VECTOR(15 downto 0);
    
    signal ALU_A_Val    : STD_LOGIC_VECTOR(15 downto 0);
    signal ALU_B_Val    : STD_LOGIC_VECTOR(15 downto 0);
    signal MAR_Out_Val  : STD_LOGIC_VECTOR(15 downto 0);
    
    signal Z_Flag_Wire  : STD_LOGIC;
    signal ALU_Op_Wire  : STD_LOGIC_VECTOR(3 downto 0);

    signal ctrl_PC_Out, ctrl_Reg_Out, ctrl_MDR_Out, ctrl_ALU_Out : STD_LOGIC;
    signal ctrl_IR_Out_Imm, ctrl_IR_Out_Addr : STD_LOGIC;
    signal ctrl_PC_In, ctrl_Reg_Write, ctrl_MAR_In, ctrl_MDR_In : STD_LOGIC;
    signal ctrl_IR_In, ctrl_A_In, ctrl_B_In : STD_LOGIC;
    signal ctrl_Mem_Read, ctrl_Mem_Write, ctrl_PC_Inc : STD_LOGIC;

    signal MDR_Input_Mux : STD_LOGIC_VECTOR(15 downto 0);
    signal Reg_Sel      : STD_LOGIC;
    signal Reg_Addr_Mux : STD_LOGIC_VECTOR(3 downto 0);

begin

    -- ==========================================
    -- 3. Port Maps (הלחמות הרכיבים לפי השמות המקוריים)
    -- ==========================================
    
    U_PC : PC_reg
    port map (
        clk         => clk,
        reset       => reset,
        PC_In       => ctrl_PC_In,
        PC_Inc      => ctrl_PC_Inc,
        address_in  => Data_Bus,     
        address_out => PC_Out_Val    
    );

    U_MAR : Reg_16bit
    port map (
        clk      => clk,
        reset    => reset,            -- הוסף חיבור איפוס
        load     => ctrl_MAR_In,
        data_in  => Data_Bus,      
        data_out => MAR_Out_Val     
    );

    U_MDR : Reg_16bit
    port map (
        clk      => clk,
        reset    => reset,
        load     => ctrl_MDR_In,
        data_in  => MDR_Input_Mux,
        data_out => MDR_Out_Val
    );

    U_IR : Reg_16bit
    port map (
        clk      => clk,
        reset    => reset,
        load     => ctrl_IR_In,
        data_in  => Data_Bus,
        data_out => IR_Full_Val
    );

    U_RegA : Reg_16bit
    port map (
        clk      => clk,
        reset    => reset,
        load     => ctrl_A_In,
        data_in  => Data_Bus,
        data_out => ALU_A_Val
    );

    U_RegB : Reg_16bit
    port map (
        clk      => clk,
        reset    => reset,
        load     => ctrl_B_In,
        data_in  => Data_Bus,
        data_out => ALU_B_Val
    );

    U_ALU : ALU
    port map (
        A_in    => ALU_A_Val,         -- תוקן מ-A
        B_in    => ALU_B_Val,         -- תוקן מ-B
        ALU_Op  => ALU_Op_Wire,
        ALU_Out => ALU_Out_Val,       -- תוקן מ-Result
        Z_Flag  => Z_Flag_Wire
    );

    U_RegFile : Register_File
    port map (
        clk       => clk,
        reset     => reset,          
        Reg_Write => ctrl_Reg_Write,
        Address   => Reg_Addr_Mux,
        Data_In   => Data_Bus,
        Data_Out  => Reg_Out_Val
    );

    U_ControlUnit : Control_Unit
    port map (
        clk         => clk,
        reset       => reset,
        Opcode      => IR_Full_Val(15 downto 12),
        Z_Flag      => Z_Flag_Wire,
        PC_Out      => ctrl_PC_Out,
        Reg_Out     => ctrl_Reg_Out,
        MDR_Out     => ctrl_MDR_Out,
        ALU_Out     => ctrl_ALU_Out,
        IR_Out_Imm  => ctrl_IR_Out_Imm,
        IR_Out_Addr => ctrl_IR_Out_Addr,
        PC_In       => ctrl_PC_In,
        Reg_Write   => ctrl_Reg_Write,
        MAR_In      => ctrl_MAR_In,
        MDR_In      => ctrl_MDR_In,
        IR_In       => ctrl_IR_In,
        A_In        => ctrl_A_In,
        B_In        => ctrl_B_In,
        Mem_Read    => ctrl_Mem_Read,
        Mem_Write   => ctrl_Mem_Write,
        PC_Inc      => ctrl_PC_Inc,
        ALU_Op      => ALU_Op_Wire
    );

    -- ==========================================
    -- 4.  ניתוב חוטים ומרבבים
    -- ==========================================
    -- לוגיקת בחירת הכתובת לארון הרגיסטרים
    Reg_Sel <= '1' when (ctrl_B_In = '1') else 
               '1' when (ctrl_Reg_Write = '1' and 
                        (IR_Full_Val(15 downto 12) = "0000" or 
                         IR_Full_Val(15 downto 12) = "0001" or 
                         IR_Full_Val(15 downto 12) = "0010" or 
                         IR_Full_Val(15 downto 12) = "0011" or 
                         IR_Full_Val(15 downto 12) = "0100" or 
                         IR_Full_Val(15 downto 12) = "0101")) else 
               '0'; 

    Reg_Addr_Mux <= IR_Full_Val(7 downto 4) when (Reg_Sel = '1') else 
                    IR_Full_Val(11 downto 8);
    
    IR_Imm_Val  <= "00000000" & IR_Full_Val(7 downto 0);
    IR_Addr_Val <= "0000"     & IR_Full_Val(11 downto 0);

    MDR_Input_Mux <= Mem_Data_In when (ctrl_Mem_Read = '1') else Data_Bus;

    Data_Bus <= PC_Out_Val   when (ctrl_PC_Out = '1') else
                ALU_Out_Val  when (ctrl_ALU_Out = '1') else
                MDR_Out_Val  when (ctrl_MDR_Out = '1') else
                Reg_Out_Val  when (ctrl_Reg_Out = '1') else
                IR_Imm_Val   when (ctrl_IR_Out_Imm = '1') else
                IR_Addr_Val  when (ctrl_IR_Out_Addr = '1') else
                (others => '0');

    Mem_Addr      <= MAR_Out_Val;
    Mem_Data_Out  <= MDR_Out_Val;
    Mem_Read_Pin  <= ctrl_Mem_Read;
    Mem_Write_Pin <= ctrl_Mem_Write;

end Structural;