----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.05.2026 09:19:10
-- Design Name: Custom 16-bit RISC CPU
-- Module Name: PC_reg - Behavioral
-- Project Name: Custom_CPU
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_reg is
    Port ( 
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        PC_In       : in  STD_LOGIC;
        PC_Inc      : in  STD_LOGIC;
        address_in  : in  STD_LOGIC_VECTOR (15 downto 0);
        address_out : out STD_LOGIC_VECTOR (15 downto 0)
    );
end PC_reg;

architecture Behavioral of PC_reg is
   
    signal pc_internal : unsigned(15 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            pc_internal <= (others => '0');
            
        elsif rising_edge(clk) then
            if PC_In = '1' then
                pc_internal <= unsigned(address_in);
            elsif PC_Inc = '1' then
                pc_internal <= pc_internal + 1;
            end if;
        end if;
    end process;

    address_out <= std_logic_vector(pc_internal);

end Behavioral;
