library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity test_prng is
end test_prng;
 
architecture Behavioral of test_prng is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component PRNG
        generic (width : integer := 32);
        port (clk : in std_logic;
              seed : in std_logic_vector(width - 1 downto 0);
              random_num : out std_logic_vector (width-1 downto 0);
              enable : in std_logic);
    end component;
    
    
    --Inputs
    signal clock : std_logic := '0';
    signal enable : std_logic := '0';
    
    signal pos : std_logic_vector(31 downto 0);
    signal seed : std_logic_vector(31 downto 0);
    signal pos40 : integer;
    
    -- Clock period
    constant clock_period : time := 10 ns;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
    uut : PRNG
        generic map (width => 32)
        port map (clk => clock,
                  seed => seed,
                  random_num => pos,
                  enable => enable);
    
    -- Clock process definitions
    clock_process : process
    begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
    		
        wait for clock_period*10;
        
        -- insert stimulus here
        
        seed <= x"fc5f9aff";
        
        enable <= '1';
        
        wait for clock_period * 100;
        
        enable <= '0', '1' after clock_period, '0' after clock_period * 2, '1' after clock_period * 3, '0' after clock_period * 4, '1' after clock_period * 5;
        
        wait for clock_period * 100;
        
        enable <= '0', '1' after clock_period * 2;
        
        wait;
        
    end process;
    
    update_pos40 : process(clock, pos)
    begin
        if rising_edge(clock) then
            pos40 <= to_integer(unsigned(pos)) mod 40;
         end if;
     end process;

end;