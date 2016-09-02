library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library briscola;
use briscola.data.all;

entity Briscola is
    generic (debounce_cycles : integer := debounce_cycles_def); -- 0.1 sec with 100 MHz
    port (clock : in std_logic;
          
          reset_btn : in std_logic;
          confirm_btn : in std_logic;
          sw : in std_logic_vector(5 downto 0);
          
          hsync : out std_logic;
          vsync : out std_logic;
          red,green,blue : out std_logic_vector(3 downto 0);
          
          speaker : out std_logic;
          ampSD : out std_logic);

end Briscola;

architecture Behavioral of Briscola is

--    component AI
--        port (clock : in std_logic;
--              reset : in std_logic;
--              briscola : in card;
--              new_card : in card;
--              enemy_card : in card;
--              turn : in std_logic;
--              card_out : out card);   
--    end component;

    component clk_wiz_2
    port (clk_in1: in std_logic;
         clk_out1: out std_logic);
     end component;
  
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
          difficulty : in std_logic;
          
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
          CARD_OUT : out card;
          done : in std_logic;
          difficulty : in std_logic);
    end component;
    
    component Player
        generic (debounce_cycles : integer := debounce_cycles_def);
        port (clock : in std_logic;
              sw : in std_logic_vector(2 downto 0);
              reset_btn : in std_logic;
              confirm_btn : in std_logic;
              card_in : in card;
              done : in std_logic;
              
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

              music_index : out integer;
              
              player_new_card : out card;
              ai_new_card : out card;
              briscola : out card;
              turn : out std_logic);
    end component;
    
    component sound
       port (clk: in std_logic;
             
             index : in integer;
            
             enable : in std_logic;
             volume : in std_logic;
            
             speaker: out std_logic;
             ampSD: out std_logic);
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
    
    signal music_index : integer;

begin    
    clock_comp : clk_wiz_2
        port map (clk_in1 => clock,
                  clk_out1 => clk);

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
                  player_points_vga => player_points,
                  music_index => music_index);
                  
    player_comp : Player
        port map (clock => clk,
                  sw => sw(2 downto 0),
                  reset_btn => reset_btn,
                  confirm_btn => confirm_btn,
                  card_in => player_card_new,
                  card_out => player_played_card,
                  reset => reset,
                  card1 => player_card1,
                  card2 => player_card2,
                  card3 => player_card3,
                  done => done);
      
    ai_comp : AI_block
        port map (CLK => clk,
                  RESET => reset,
                  BRISCOLA_INFOS => brisc,
                  DRAWN_CARD => ai_card_new,
                  OPPONENT_CARD => player_played_card,
                  CARD_OUT => ai_played_card,
                  TURN => turn,
                  done => done,
                  difficulty => sw(5));
                  
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
                  turn => turn,
                  difficulty => sw(5));
                  
    snd : sound
        port map(clk => clk,
                 index => music_index,
                          
                 enable => sw(3),
                 volume => sw(4),
                          
                 speaker => speaker,
                 ampSD => ampSD);

end Behavioral;