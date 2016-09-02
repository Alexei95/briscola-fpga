library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library briscola;
use briscola.data.all;

entity Loader is
	Port(	CLK: in STD_LOGIC;
			CARD_IN:in card; --drawn card
			HAND_IN: in hand; --from memory cells
			ERASE: in STD_LOGIC; --true formats all
			DISCARD: in integer range 0 to 3; --index of the card to be dropped
			HAND_UPDATE: out hand; --to memory cells
			SELECTOR: out STD_LOGIC_VECTOR(0 to 2):="000"); --enable signals of memory cells
end Loader;

architecture Behavioral of Loader is
begin

	CHECK: process(CARD_IN, HAND_IN,CLK) is
		variable foundhole : boolean := false;
		variable hole: integer range 0 to 2:= 0;
		begin
		if rising_edge(CLK) then
			foundhole:=false;
			hole:=0;
			SELECTOR<="000";
			if (CARD_IN.value /=EMPTY) and (CARD_IN.value /= HAND_IN(0).value or CARD_IN.suit /= HAND_IN(0).suit) and (CARD_IN.value /= HAND_IN(1).value or CARD_IN.suit /= HAND_IN(1).suit) and (CARD_IN.value /= HAND_IN(2).value or CARD_IN.suit /= HAND_IN(2).suit) then --if a (drawn) card is really approaching
			    
				for i in 0 to 2 loop
					if ( (HAND_IN(i).value=EMPTY) and (foundhole = false)) then
						HAND_UPDATE(i)<=CARD_IN;
						hole:=i;
						foundhole:=true;
					end if;
				end loop;
				
				if (hole=0) then
					SELECTOR <= "100";
				elsif (hole=1) then
					SELECTOR <= "010";
				elsif(hole=2) then
					SELECTOR <= "001";
				end if;
				
			end if;
			
			if(ERASE='1') then --format the hand
				SELECTOR <= "111";
				HAND_UPDATE(0).value<=EMPTY;
				HAND_UPDATE(1).value<=EMPTY;
				HAND_UPDATE(2).value<=EMPTY;
			end if;
		
			if (DISCARD<3) then --a card has been played from AI, needs to be dropped!
			
				HAND_UPDATE(DISCARD).value<=EMPTY;
				if (DISCARD=0) then
					SELECTOR <= "100";
				elsif (DISCARD=1) then
					SELECTOR <= "010";
				elsif(DISCARD=2) then
					SELECTOR <= "001";
				end if;
				
			end if;
			
		end if;
	end process CHECK;
	
end Behavioral;

