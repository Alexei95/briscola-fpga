library ieee;
use ieee.std_logic_1164.all;

library briscola;
use briscola.data.all;
 
entity test_internal_block is
end test_internal_block;
 
architecture Behavioral of test_internal_block is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component AI_block
    port (DRAWN_CARD : in card;
          OPPONENT_CARD: in card;
          BRISCOLA_INFOS : in card;
          RESET : in  STD_LOGIC;
          TURN : in  STD_LOGIC;
          CARD_OUT : out card;
          CLK: in STD_LOGIC);
    end component;   
    
    component Player
        generic (debounce_cycles : integer := debounce_cycles_def);
        port (clock : in std_logic;
              sw : in std_logic_vector(2 downto 0);
              reset_btn : in std_logic;
              confirm_btn : in std_logic;
              card_in : in card;
              
              card_out : out card;
              reset : out std_logic);
              
    end component;
    
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
    
    signal reset : std_logic;
    signal player_card : card;
    signal ai_card : card;
    signal player_card_new : card;
    signal ai_card_new : card;
    signal briscola : card;
    signal turn : std_logic;
    
    
    --Inputs
    signal clock : std_logic := '0';
    signal reset_btn : std_logic;
    signal confirm_btn : std_logic;
    
    signal sw : std_logic_vector(2 downto 0);
    
    -- Clock period
    constant clock_period : time := 10 ns;
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
    server_comp : Server
        port map (clock => clock,
                  player_card => player_card,
                  ai_card => ai_card,
                  player_new_card => player_card_new,
                  ai_new_card => ai_card_new,
                  reset => reset,
                  briscola => briscola,
                  turn => turn);
                  
    player_comp : Player
        generic map (debounce_cycles => 10) -- 100 ns
        port map (clock => clock,
                  sw => sw,
                  reset_btn => reset_btn,
                  confirm_btn => confirm_btn,
                  card_in => player_card_new,
                  card_out => player_card,
                  reset => reset);
      
    ai_comp : AI_block
        port map (CLK => clock,
                  RESET => reset,
                  BRISCOLA_INFOS => briscola,
                  DRAWN_CARD => ai_card_new,
                  OPPONENT_CARD => player_card,
                  CARD_OUT => ai_card,
                  TURN => turn);
    
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

        
        reset_btn <= '0', '1' after 110 ns; -- must be inverted because it simulates CPU RES BUT
        confirm_btn <= '1', '0' after 110 ns;
        
        wait for 2 us;
        
        sw <= b"001", b"000" after 110 ns;
        confirm_btn <= '1', '0' after 110 ns;
        
        wait for 200 ns;
        
        sw <= b"100", b"000" after 110 ns;
        confirm_btn <= '1', '0' after 110 ns;
        
        wait for 1 us;
        
        sw <= b"000";
        reset_btn <= '0', '1' after 110 ns; -- must be inverted because it simulates CPU RES BUT
        confirm_btn <= '1', '0' after 110 ns;
        
        wait;
        
        -- end game test
        
    end process;

end;
