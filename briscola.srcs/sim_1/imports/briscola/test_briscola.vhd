library ieee;
use ieee.std_logic_1164.all;

library briscola;
use briscola.data.all;
 
entity test_briscola is
end test_briscola;
 
architecture Behavioral of test_briscola is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component Briscola
        generic (debounce_cycles : integer := debounce_cycles_def); -- 0.1 sec with 100 MHz
        port (clock : in std_logic;
              reset_btn : in std_logic;
              confirm_btn : in std_logic;
              sw : in std_logic_vector(2 downto 0));
    end component;
    
    
    --Inputs
    signal clock : std_logic := '0';
    signal reset_btn : std_logic;
    signal confirm_btn : std_logic;
    
    signal sw : std_logic_vector(2 downto 0);
    
    -- Clock period
    constant clock_period : time := 10 ns;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
    uut: Briscola
    port map (clock => clock,
              reset_btn => reset_btn,
              confirm_btn => confirm_btn,
              
              sw => sw);
    
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
        
        reset_btn <= '1', '0' after 0.1 sec;
        confirm_btn <= '1', '0' after 0.2 sec;
        
        wait;
    end process;

end;