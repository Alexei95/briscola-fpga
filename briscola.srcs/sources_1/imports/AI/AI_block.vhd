library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library briscola;
use briscola.data.all;

entity AI_block is
    Port ( DRAWN_CARD : in card;
			  OPPONENT_CARD: in card;
           BRISCOLA_INFOS : in card;
			  CLK: in STD_LOGIC;
           RESET : in  STD_LOGIC;
           TURN : in  STD_LOGIC;
           CARD_OUT : out card;
           done : in std_logic;
           difficulty : in std_logic);
end AI_block;

architecture structure of AI_block is

	component Manager
		Port( CLK: in STD_LOGIC;
				DRAWN_CARD : in  card;
				ERASE : in  STD_LOGIC;
				DISCARD_IN: in integer range 0 to 3;
				HAND_OUT : out hand);
	end component;
	
	component Chooser
	Port( CLK: in STD_LOGIC;
			HAND_IN: in hand;
			TURN: in STD_LOGIC;
			BRISCOLA: in card;
			OPPONENT_CARD: in card;
			CHOSEN_CARD: out card;
			DISCARD_OUT: out integer range 0 to 3;
			done : in std_logic;
			difficulty : in std_logic);
	end component;
	signal AI_HAND: hand;
	signal DISCARD: integer range 0 to 3;
	begin
		CARD_MANAGER: manager port map (CLK => CLK,DRAWN_CARD => DRAWN_CARD,ERASE=>RESET,HAND_OUT=>AI_HAND,DISCARD_IN=>DISCARD);
		CARD_CHOOSER: chooser port map (done => done, difficulty => difficulty, CLK => CLK,HAND_IN => AI_HAND,TURN => TURN,BRISCOLA => BRISCOLA_INFOS,OPPONENT_CARD => OPPONENT_CARD,CHOSEN_CARD => CARD_OUT,DISCARD_OUT=>DISCARD);
	end structure;
	
	
	
	