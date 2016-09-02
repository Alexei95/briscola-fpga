library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library briscola;
use briscola.data.all;

entity chooser is
	Port( CLK: in STD_LOGIC;
			HAND_IN: in hand; --hand of AI
			TURN: in STD_LOGIC; --enable of the chooser as first or second depending on '1' or '0'
			BRISCOLA: in card; --briscola info for this match
			OPPONENT_CARD: in card; --card played by USER
			CHOSEN_CARD: out card; --card played by AI
			DISCARD_OUT: out integer range 0 to 3; --index of the card played sent to card manager to be removed
			difficulty : in std_logic;
			done : in std_logic);
end chooser;

architecture Behavioral of chooser is
	type vector is array (0 to 2) of integer;

begin
	CLOCK: process(CLK, OPPONENT_CARD) is
	
		variable cpustrength: integer range 0 to 31;
		variable opstrength: integer range 0 to 31;
		variable choice: integer range 0 to 2 := 0;
		variable taken: boolean;
		variable appetibility: vector;
		variable strength: vector;
		variable minpoints: integer;
		variable maxpoints : integer;
		variable minstrength: integer range 0 to 31;
		
		variable played : std_logic := '0';
		
		begin
		if rising_edge(CLK) then
		    if done = '1' then
                if TURN = '1' and played /= '1' and OPPONENT_CARD.value = EMPTY then -- activated
                    --play-first algorithm
                    
                    choice:=0;
                    minpoints:=12;
                    minstrength:=31;
                    --for choice in 0 to 2 loop
                    --    if (HAND_IN(choice).value/=EMPTY) then 
                    --        exit;
                    --    end if;
                    --end loop;
                    for i in 0 to 2 loop --main loop among three cards
                        strength(i):=0;
                        if (HAND_IN(i).value/=EMPTY) then
                            if (HAND_IN(i).suit=BRISCOLA.suit) then
                                strength(i):=strength(i)+20;
                            end if;
                            if (HAND_IN(i).points<minpoints) then
                                minpoints:=HAND_IN(i).points;
                                minstrength:=strength(i);
                                choice:=i;
                            else
                                if (HAND_IN(i).points = minpoints and strength(i) < minstrength) then
                                    minpoints:=HAND_IN(i).points;
                                    minstrength:=strength(i);
                                    choice:=i;
                                end if;
                            end if;
                        end if;
                    end loop;
                    
                    if (choice<0 or choice>2) then
                        choice:=0; --just in case
                    end if;
                    
                    --final output initialization
                    CHOSEN_CARD<=HAND_IN(choice);
                    DISCARD_OUT<=choice;
                    played := '1';
                elsif (TURN = '1' and OPPONENT_CARD.value /= EMPTY and played /= '1') then -- activated by second
                        
                        --play-second algorithm
                        --HARD
                        if difficulty = '0' then
                            choice:=0;
                            cpustrength:=0;
                            opstrength:=0;
                            taken:=false;
                            
                            if(OPPONENT_CARD.suit=BRISCOLA.suit) then
                                opstrength:=20;
                            else
                                opstrength:=10;
                            end if;
                            --for choice in 0 to 2 loop
                            --    if (HAND_IN(choice).value/=EMPTY) then 
                            --        exit;
                            --    end if;
                            --end loop;
                            for i in 0 to 2 loop --main loop among three cards
                                if(HAND_IN(i).value/=EMPTY) then
                                
                                    taken:=false;
                                    appetibility(i):=0;
                                    cpustrength:=0;
                                    
                                    if(HAND_IN(i).suit=BRISCOLA.suit) then
                                        cpustrength:=20;
                                    end if;
                                    
                                    if(HAND_IN(i).suit=OPPONENT_CARD.suit) then
                                    
                                        if(OPPONENT_CARD.suit/=BRISCOLA.suit) then
                                            cpustrength:=10;
                                        end if;
                                        
                                        if(OPPONENT_CARD.points<HAND_IN(i).points) then
                                            cpustrength:=cpustrength+1;
                                        else 
                                            cpustrength:=cpustrength-1;
                                        end if;
                                        
                                    end if;
                                    
                                    if(cpustrength>opstrength) then
                                        taken:=true;
                                    end if;
            
                                    if (taken=true) then
                                        if(HAND_IN(i).suit=BRISCOLA.suit) then
                                            if(OPPONENT_CARD.points=0) then
                                                appetibility(i):=0;
                                            elsif (HAND_IN(i).points=0) then
                                                appetibility(i):= OPPONENT_CARD.points*HAND_IN(i).points*1000;
                                            else
                                                appetibility(i):= OPPONENT_CARD.points*1000;
                                            end if;
                                        else
                                            if(HAND_IN(i).points=0 and OPPONENT_CARD.points=0) then
                                                appetibility(i):=0;
                                            else 
                                                appetibility(i):=(OPPONENT_CARD.points+HAND_IN(i).points)*1000*HAND_IN(i).points;
                                            end if;
                                        end if;
                                        
                                    else
                                        if(HAND_IN(i).points=-OPPONENT_CARD.points) then
                                            appetibility(i):=HAND_IN(i).points+1;
                                        else 
                                            appetibility(i):= -(OPPONENT_CARD.points + HAND_IN(i).points)*(HAND_IN(i).points)*1000;
                                        end if;
                                    end if;
                                    
                                else
                                    appetibility(i):=-3000*(HAND_IN(i).points+1)*1000;
                                end if;
                            end loop;	
                            --final choice
                            for i in 0 to 2 loop
                                if(appetibility(i)>appetibility(choice))then
                                    choice:=i;
                                elsif(appetibility(i)=appetibility(choice)) then
                                    if(HAND_IN(i).points< HAND_IN(choice).points) then
                                        choice:=i;
                                    end if;
                                end if;
                            end loop;
                        else
                            --EASY
                            --!!!!! easy mode algorithm starts here 
                            choice:=0;
                            cpustrength:=0;
                            minpoints:=23;
                            minstrength:=31;
                            maxpoints:=-1;
                            opstrength:=0;
                            taken:=false;
                            
                            if(OPPONENT_CARD.suit=BRISCOLA.suit) then
                                opstrength:=20;
                            else
                                opstrength:=10;
                            end if;
                            --for choice in 0 to 2 loop
                            --    if (HAND_IN(choice).value/=EMPTY) then 
                            --        exit;
                            --    end if;
                            --end loop;
                            for i in 0 to 2 loop --main loop among three cards
                                if(HAND_IN(i).value/=EMPTY) then
                                
                                    taken:=false;
                                    cpustrength:=0;
                                    
                                    if(HAND_IN(i).suit=BRISCOLA.suit) then
                                        cpustrength:=20;
                                    end if;
                                    
                                    if(HAND_IN(i).suit=OPPONENT_CARD.suit) then
                                    
                                        if(OPPONENT_CARD.suit/=BRISCOLA.suit) then
                                            cpustrength:=10;
                                        end if;
                                        
                                        if(OPPONENT_CARD.points<HAND_IN(i).points) then
                                            cpustrength:=cpustrength+1;
                                        else 
                                            cpustrength:=cpustrength-1;
                                        end if;
                                        
                                    end if;
                                    
                                    if(cpustrength>opstrength) then
                                        taken:=true;
                                        maxpoints:=HAND_IN(i).points+OPPONENT_CARD.points;
                                        minstrength:= cpustrength;
                                        choice:=i;
                                    end if;
            
                                    if (taken=false) then
                                        if(HAND_IN(i).points + OPPONENT_CARD.points>maxpoints) then
                                            minpoints:=HAND_IN(i).points + OPPONENT_CARD.points;
                                            minstrength:= cpustrength;
                                            choice:=i;
                                        end if;
                                    else
                                        if(HAND_IN(i).points + OPPONENT_CARD.points=maxpoints) then
                                            minstrength:=cpustrength;
                                            choice:=i;
                                        end if;
                                    end if;
                                end if;
                            end loop;
                        end if;
                        --end second-move
                        --final output initialization
                        CHOSEN_CARD<=HAND_IN(choice);
                        DISCARD_OUT<=choice;
                        played := '1';
                else -- not AI turn or waiting time
                    CHOSEN_CARD <= (value=>EMPTY, suit => COINS, points => 0);
                    DISCARD_OUT<=3;
                    played := '0'; -- played is used to avoid sending again a new card, which will also cause disruption in internal memory since it lags by 2 clock cycles
                end if;
            end if;
		end if;
	end process CLOCK;
end Behavioral;

