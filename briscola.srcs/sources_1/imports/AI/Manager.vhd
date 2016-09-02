library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library briscola;
use briscola.data.all;

entity Manager is

	Port( 	CLK: in STD_LOGIC;
				DRAWN_CARD : in  card;
				ERASE : in  STD_LOGIC;
				DISCARD_IN: in integer range 0 to 3;
				HAND_OUT : out hand);
end Manager;

architecture structure of Manager is
	
	component Loader
	
	Port(	CLK: in STD_LOGIC;
			CARD_IN:in card;
			HAND_UPDATE: out hand;
			HAND_IN: in hand;
			ERASE: in STD_LOGIC;
			DISCARD: in integer range 0 to 3;
			SELECTOR: out STD_LOGIC_VECTOR(0 to 2));
	end component;
	
	component Card_Memory
	Port(CARD_IN: in card;
		  CARD_OUT:out card;
		  CLK: in STD_LOGIC;
		  WRITE_IN: in STD_LOGIC:='0');
	end component;
	
	signal frommemory: hand;
	signal tomemory: hand;
	signal enable: std_logic_vector(0 to 2) := b"000";
	begin
		CARD_LOADER: Loader port map (CLK=>CLK,CARD_IN => DRAWN_CARD, HAND_UPDATE=>tomemory, HAND_IN=>frommemory, ERASE=>ERASE,SELECTOR=>enable, DISCARD=>DISCARD_IN);
		CARD1: Card_Memory port map (CARD_IN => tomemory(0), CARD_OUT => frommemory(0), WRITE_IN => enable(0),CLK=>CLK);
		CARD2: Card_Memory port map (CARD_IN => tomemory(1), CARD_OUT => frommemory(1), WRITE_IN => enable(1),CLK=>CLK);
		CARD3: Card_Memory port map (CARD_IN => tomemory(2), CARD_OUT => frommemory(2), WRITE_IN => enable(2),CLK=>CLK);
		HAND_OUT<=frommemory;
end structure;