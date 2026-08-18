----------------------------------------------------------------------------------

-- Module Name: CPU_TB - Behavioral

----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity CPU_TB is

end CPU_TB;

architecture Behavioral of CPU_TB is

    component CPU_TopLevel
        Port ( 
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            Mem_Addr     : out STD_LOGIC_VECTOR(15 downto 0);
            Mem_Data_In  : in  STD_LOGIC_VECTOR(15 downto 0);
            Mem_Data_Out : out STD_LOGIC_VECTOR(15 downto 0);
            Mem_Read_Pin : out STD_LOGIC;
            Mem_Write_Pin: out STD_LOGIC
        );
    end component;

    -- כבלי החשמל (שעון ואיפוס) מקבלים אפס התחלתי כדי לא להיות באוויר
    signal tb_clk          : STD_LOGIC := '0';
    signal tb_reset        : STD_LOGIC := '0';
    
    -- כבלי התקשורת לזיכרון
    signal tb_Mem_Addr     : STD_LOGIC_VECTOR(15 downto 0);
    signal tb_Mem_Data_In  : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal tb_Mem_Data_Out : STD_LOGIC_VECTOR(15 downto 0);
    signal tb_Mem_Read_Pin : STD_LOGIC;
    signal tb_Mem_Write_Pin: STD_LOGIC;

    -- הגדרת קבוע זמן עבור השעון (נוח מאוד כדי לשנות את התדר בהמשך)
    constant CLK_PERIOD : time := 10 ns;
    
    type ram_type is array (0 to 31) of STD_LOGIC_VECTOR(15 downto 0);
    signal RAM : ram_type := (
        0 => "1010000100001010", -- LDI R1, 10
        1 => "1010001000000011", -- LDI R2, 3
        2 => "0011000100100000", -- MOD R1, R2 (Result goes to R2)
        3 => "1001001000000000", -- STORE R2
        4 => "1111000000000000", -- HALT
        others => (others => '0') 
    );
    
    begin

    DUT : CPU_TopLevel
    port map (
        clk           => tb_clk,
        reset         => tb_reset,
        Mem_Addr      => tb_Mem_Addr,
        Mem_Data_In   => tb_Mem_Data_In,
        Mem_Data_Out  => tb_Mem_Data_Out,
        Mem_Read_Pin  => tb_Mem_Read_Pin,
        Mem_Write_Pin => tb_Mem_Write_Pin
    );
    
    clk_process :process
    begin
        tb_clk <= '0';
        wait for CLK_PERIOD/2;
        tb_clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    reset_process: process
    begin
        tb_reset <= '1';
        wait for 20 ns;
        tb_reset <= '0';
        wait;
    end process;

    RAM_Write_Process: process(tb_clk)
    begin
        if rising_edge(tb_clk) then
            if tb_Mem_Write_Pin = '1' then
                RAM(to_integer(unsigned(tb_Mem_Addr))) <= tb_Mem_Data_Out;
            end if;
        end if;
    end process;

    tb_Mem_Data_In <= RAM(to_integer(unsigned(tb_Mem_Addr))) when (tb_Mem_Read_Pin = '1') else (others => '0');
end Behavioral;