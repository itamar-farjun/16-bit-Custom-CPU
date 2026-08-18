----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.05.2026 01:38:51
-- Design Name: 
-- Module Name: Register_File - Behavioral
-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_File is
    Port ( 
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        Reg_Write  : in  STD_LOGIC;
        Address    : in  STD_LOGIC_VECTOR (3 downto 0);
        Data_In    : in  STD_LOGIC_VECTOR (15 downto 0);
        Data_Out   : out STD_LOGIC_VECTOR (15 downto 0)
    );
end Register_File;

architecture Behavioral of Register_File is
    
    type reg_array is array (0 to 15) of STD_LOGIC_VECTOR (15 downto 0);
    
    signal registers : reg_array;
begin

    process(clk, reset)
    begin
        if reset = '1' then
            for i in 0 to 15 loop
                registers(i) <= (others => '0');
            end loop;
            
        elsif rising_edge(clk) then
            if Reg_Write = '1' then
                registers(to_integer(unsigned(Address))) <= Data_In;
            end if;
        end if;
    end process;

    Data_Out <= registers(to_integer(unsigned(Address))); --Operates continuously

end Behavioral;
