library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library briscola;
use briscola.data.all;

entity CARD_MEMORY is
	Port(CARD_IN: in card;
		  CARD_OUT:out card;
		  CLK: in STD_LOGIC;
		  WRITE_IN: in STD_LOGIC:='0');
end CARD_MEMORY;


architecture Behavioral of CARD_MEMORY is
	
begin
	dff: process(WRITE_IN,CARD_IN,CLK) is
		begin
		if rising_edge(CLK) then
			if(WRITE_IN='1') then --WRITE is enabled, overwrite the card in the FF
				CARD_OUT<=CARD_IN;
			end if;
		end if;
	end process dff;
end Behavioral;

