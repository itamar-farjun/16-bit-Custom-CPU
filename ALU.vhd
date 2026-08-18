----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.05.2026 01:19:55
-- Design Name: 
-- Module Name: ALU - Behavioral
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( 
        A_in    : in  STD_LOGIC_VECTOR (15 downto 0);
        B_in    : in  STD_LOGIC_VECTOR (15 downto 0);
        ALU_Op  : in  STD_LOGIC_VECTOR (3 downto 0);
        ALU_Out : out STD_LOGIC_VECTOR (15 downto 0);
        Z_Flag  : out STD_LOGIC
    );
end ALU;

architecture Behavioral of ALU is
    signal A_uns : unsigned(15 downto 0);
    signal B_uns : unsigned(15 downto 0);
    signal result_internal : unsigned(15 downto 0);
    
begin

    A_uns <= unsigned(A_in);
    B_uns <= unsigned(B_in);
    
    process(A_uns, B_uns, ALU_Op)
    begin
        case ALU_Op is
            when "0000" => -- (ADD)
                result_internal <= A_uns + B_uns;
                
            when "0001" => -- (SUB)
                result_internal <= A_uns - B_uns;
                
            when "0010" => -- (DIV)
                if B_uns /= 0 then
                    result_internal <= A_uns / B_uns;
                else
                    result_internal <= (others => '0'); -- Division by zero protection
                end if;
            
            when "0011" => -- (MOD)
                if B_uns /= 0 then
                    result_internal <= A_uns mod B_uns;
                else
                    result_internal <= (others => '0');
                end if;
                
            when "0100" => -- (AND)
                result_internal <= A_uns and B_uns;
                
            when "0101" => -- (OR)
                result_internal <= A_uns or B_uns;
            when others => -- default
                result_internal <= (others => '0');
        end case;
    end process;
    
    ALU_Out <= std_logic_vector(result_internal);
    
    Z_Flag <= '1' when result_internal = 0 else '0';

end Behavioral;
    