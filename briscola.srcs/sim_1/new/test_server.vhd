library ieee;
use ieee.std_logic_1164.all;

library briscola;
use briscola.data.all;
 
entity test_server is
end test_server;
 
architecture Behavioral of test_server is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component Server
    generic (max_turns : integer := 20);
    port (clock : in std_logic;
          player_card : in card;
          ai_card : in card;
          reset : in std_logic;
          
          player_new_card : out card;
          ai_new_card : out card;
          briscola : out card;
          turn : out std_logic);
    end component;
    
    
    --Inputs
    signal clock : std_logic := '0';
    signal player_card : card;
    signal ai_card : card;
    signal reset : std_logic;
    
    signal player_new_card : card;
    signal ai_new_card : card;
    signal briscola : card;
    signal turn : std_logic;
    
    -- Clock period
    constant clock_period : time := 10 ns;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
    uut: Server
    port map (clock => clock,
              player_card => player_card,
              ai_card => ai_card,
              reset => reset,
                
              player_new_card => player_new_card,
              ai_new_card => ai_new_card,
              briscola => briscola,
              turn => turn);
    
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
        
        reset <= '1', '0' after 100 ns, '1' after 600 ns, '0' after 700 ns;
        
        player_card.value <= THREE;
        player_card.suit <= CLUBS;
        
        ai_card.value <= HORSE;
        ai_card.suit <= CLUBS;
        
        wait;
    end process;

end;
