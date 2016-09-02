library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity PRNG is
    generic (width : integer := 32);
    port (clk : in std_logic;
          random_num : out std_logic_vector (width-1 downto 0);
          seed : in std_logic_vector(width - 1 downto 0) := (width - 1 => '1', others => '0');
          enable : in std_logic);
end PRNG;

architecture Behavioral of PRNG is
    constant zeros : std_logic_vector(width-1 downto 0) := std_logic_vector(to_unsigned(0, width));
begin

    process(clk, enable)
        variable rand_temp : std_logic_vector(width-1 downto 0); 
        variable temp : std_logic := '0';
    begin
        if(rising_edge(clk)) then
            if enable = '1' then
                if rand_temp = zeros then
                    if seed /= zeros then
                        rand_temp := seed;
                    else
                        rand_temp := (width - 1 => '1', others => '0');
                    end if;
                end if;
                temp := rand_temp(width - 1) xor rand_temp(width - 2);
                rand_temp(width - 1 downto 1) := rand_temp(width - 2 downto 0);
                rand_temp(0) := temp;
                
                random_num <= rand_temp;
            else
                rand_temp := zeros;
            end if;
        end if;
    end process;
    
end Behavioral;
