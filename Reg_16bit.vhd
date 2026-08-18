----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.05.2026 23:25:44
-- Module Name: Reg_16bit - Behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Reg_16bit is
    Port ( 
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        load     : in  STD_LOGIC;
        data_in  : in  STD_LOGIC_VECTOR (15 downto 0);
        data_out : out STD_LOGIC_VECTOR (15 downto 0)
    );
end Reg_16bit;
architecture Behavioral of Reg_16bit is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            data_out    <= (others => '0');
            
        elsif rising_edge(clk) then
            if load = '1' then
                data_out <= data_in;
            end if;
        end if;
    end process;
end Behavioral;