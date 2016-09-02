library ieee;
use ieee.std_logic_1164.all;

library briscola;
use briscola.data.all;

entity test_everything is
end test_everything;

architecture Behavioral of test_everything is

    -- Component Declaration for the Unit Under Test (UUT)
    component vga_top
    port (
          CLK: in std_logic;
          player_card1 : in card;
          player_card2 : in card;
          player_card3 : in card;
          player_played_card : in card;
          ai_played_card : in card;
          briscola : in card;
          n_turns : in integer;
          ai_points : in integer;
          player_points : in integer;
          turn : in std_logic; -- 0 player 1 ai
          
          hsync : out std_logic;
          vsync : out std_logic;
          red,green,blue : out std_logic_vector(3 downto 0);
          done : out std_logic
          );
    end component;

    component AI_block
    Port (DRAWN_CARD : in card;
		  OPPONENT_CARD: in card;
          BRISCOLA_INFOS : in card;
		  CLK: in STD_LOGIC;
          RESET : in  STD_LOGIC;
          TURN : in  STD_LOGIC;
          CARD_OUT : out card);
    end component;
    
    component Player
        generic (debounce_cycles : integer := debounce_cycles_def);
        port (clock : in std_logic;
              sw : in std_logic_vector(2 downto 0);
              reset_btn : in std_logic;
              confirm_btn : in std_logic;
              card_in : in card;
              
              card_out : out card;
              reset : out std_logic;
              card1 : out card;
              card2 : out card;
              card3 : out card);
              
    end component;
    
    component Server
        generic (max_turns : integer := 20);
        port (clock : in std_logic;
              player_card : in card;
              ai_card : in card;
              reset : in std_logic;
              done : in std_logic;
              
              player_played_card : out card;
              ai_played_card : out card;
              n_turns : out integer;
              ai_points_vga : out integer;
              player_points_vga : out integer;

              
              player_new_card : out card;
              ai_new_card : out card;
              briscola : out card;
              turn : out std_logic);
    end component;
    
    signal clk : std_logic;
    signal reset : std_logic;
    signal player_played_card : card;
    signal ai_played_card : card;
    signal player_card_new : card;
    signal ai_card_new : card;
    signal brisc : card;
    signal turn : std_logic;
    signal done : std_logic;
    
    signal player_card1 : card;
    signal player_card2 : card;
    signal player_card3 : card;
    signal player_played_card_vga : card;
    signal ai_played_card_vga : card;
    signal n_turns : integer;
    signal ai_points : integer;
    signal player_points: integer;
    
    
    --Inputs
    --signal clock : std_logic := '0';
    signal reset_btn : std_logic;
    signal confirm_btn : std_logic;
    
    signal hsync, vsync : std_logic;
    signal red,green,blue : std_logic_vector(3 downto 0);
    
    signal sw : std_logic_vector(2 downto 0);
    
    -- Clock period
    --constant clock_period : time := 39.721946375372393247269116186693 ns; -- 25.175 MHz
    constant clock_period : time := 10 ns; -- 100 MHz
 
begin
 
	-- Instantiate the Unit Under Test (UUT)
    server_comp : Server
        port map (clock => clk,
                  player_card => player_played_card,
                  ai_card => ai_played_card,
                  player_new_card => player_card_new,
                  ai_new_card => ai_card_new,
                  reset => reset,
                  briscola => brisc,
                  turn => turn,
                  done => done,
                  player_played_card => player_played_card_vga,
                  ai_played_card => ai_played_card_vga,
                  n_turns => n_turns,
                  ai_points_vga => ai_points,
                  player_points_vga => player_points);
                  
    player_comp : Player
        port map (clock => clk,
                  sw => sw,
                  reset_btn => reset_btn,
                  confirm_btn => confirm_btn,
                  card_in => player_card_new,
                  card_out => player_played_card,
                  reset => reset,
                  card1 => player_card1,
                  card2 => player_card2,
                  card3 => player_card3);
      
    ai_comp : AI_block
        port map (CLK => clk,
                  RESET => reset,
                  BRISCOLA_INFOS => brisc,
                  DRAWN_CARD => ai_card_new,
                  OPPONENT_CARD => player_played_card,
                  CARD_OUT => ai_played_card,
                  TURN => turn);
                  
    vga : vga_top
        port map (CLK => clk,
                  hsync => hsync,
                  vsync => vsync,
                  red => red,
                  green => green,
                  blue => blue,
                  done => done,
                  player_card1 => player_card1,
                  player_card2 => player_card2,
                  player_card3 => player_card3,
                  player_played_card => player_played_card_vga,
                  ai_played_card => ai_played_card_vga,
                  briscola => brisc,
                  n_turns => n_turns,
                  ai_points => ai_points,
                  player_points => player_points,
                  turn => turn);
    
    -- Clock process definitions
    clock_process : process
    begin
        clk <= '0';
        wait for clock_period/2;
        clk <= '1';
        wait for clock_period/2;
    end process;
    
    
    -- Stimulus process
    stim_proc: process
    begin		
        wait for clock_period*10;
        
        -- insert stimulus here

        
        --reset_btn <= '0', '1' after 110 ns; -- must be inverted because it simulates CPU RES BUT
        --confirm_btn <= '1', '0' after 110 ns;
        
        wait for 2 us;
        
--        sw <= b"001", b"000" after 110 ns;
--        confirm_btn <= '1', '0' after 110 ns;
        
--        wait for 200 ns;
        
--        sw <= b"100", b"000" after 110 ns;
--        confirm_btn <= '1', '0' after 110 ns;
        
--        wait for 1 us;
        
--        sw <= b"000";
--        reset_btn <= '0', '1' after 110 ns; -- must be inverted because it simulates CPU RES BUT
--        confirm_btn <= '1', '0' after 110 ns;
        
--        wait;
        
        -- end game test
        
    end process;

end Behavioral;
