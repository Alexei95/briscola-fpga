library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library briscola;
use briscola.data.all;

entity vga_top is
  port(
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
    difficulty : in std_logic; -- 0 hard 1 easy
    
    hsync : out std_logic;
    vsync : out std_logic;
    red,green,blue : out std_logic_vector(3 downto 0);
    done : out std_logic
  );
end vga_top;

architecture main of vga_top is

signal clr,vidon,enable,vsenable : std_logic;
signal hc,vc: std_logic_vector(9 downto 0);
signal M: std_logic_vector(11 downto 0);
signal rom_address18: std_logic_vector(17 downto 0);


component vgasync is 
    port (clk, clr : in std_logic;
          hsync : out std_logic;
          vsync : out std_logic;
          hc : out std_logic_vector(9 downto 0);
          vc : out std_logic_vector(9 downto 0);
          vidon : out std_logic;
          vsenable : out std_logic
          );
end component vgasync;
component vga_drawer is
  port( clk : in std_logic;
        vidon: in std_logic;
        hc: in std_logic_vector(9 downto 0); --11 bits for 1688 
        vc: in std_logic_vector(9 downto 0); --11 bits for 1066
        M: in std_logic_vector(11 downto 0); --vga colors
        player_card1 : in card;
        player_card2 : in card;
        player_card3 : in card;
        ai_played_card : in card;
        player_played_card : in card;
        briscola : in card;
        n_turns : in integer;
        ai_points : in integer;
        player_points : in integer;
        turn_in : in std_logic; -- 0 player 1 ai
        difficulty : in std_logic;
        
        rom_address18: out std_logic_vector(17 downto 0); --to address rom of 5500 cells
        red: out std_logic_vector(3 downto 0);
        green: out std_logic_vector(3 downto 0);
        blue: out std_logic_vector(3 downto 0);
        done : out std_logic
      );
end component vga_drawer;
component blk_mem_gen_0 is
  port (
    clka : in std_logic;
    ena : in std_logic;
    addra : in std_logic_vector(17 downto 0);
    douta : out std_logic_vector(11 downto 0)
  );
end component blk_mem_gen_0;

begin
    enable <= '1';
    clr <= '0'; 
    U2 : vgasync
         port map(clk=>clk, clr=>clr, hsync=>hsync, vsync=>vsync, hc=>hc, vc=>vc, vidon=>vidon, vsenable=>vsenable);
    U3 : vga_drawer
         port map(turn_in => turn, clk => clk, vidon=>vidon, hc=>hc, vc=>vc, M=>M, rom_address18=>rom_address18,
                  red=>red, green=>green, blue=>blue, done => done, player_card1 => player_card1, player_card2 => player_card2,
                  player_card3 => player_card3, ai_played_card => ai_played_card, player_played_card => player_played_card,
                  briscola => briscola, n_turns => n_turns, ai_points => ai_points, player_points => player_points, difficulty => difficulty);
    U4 : blk_mem_gen_0
         port map(clka=>clk, ena=>enable, addra=>rom_address18, douta=>M);
end main; 
    