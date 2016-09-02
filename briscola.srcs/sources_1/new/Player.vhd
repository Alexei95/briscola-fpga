library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library briscola;
use briscola.data.all;

entity Player is
    generic (debounce_cycles : integer := debounce_cycles_def); -- 0.1 sec from 100 MHz clock
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
          
end Player;

architecture Behavioral of Player is
    -- The rightmost card is card1, as well as the first position in sw which should be connected to the rightmost switch
    signal confirm_sgl : std_logic;
    signal reset_sgl : std_logic;

begin

    confirm_checker : process(clock, confirm_btn)
        variable counter : positive := 1;
        variable already_pressed : std_logic := '0';
    begin
        if rising_edge(clock) then
            if confirm_btn = '1' and already_pressed = '0' then
                if counter < debounce_cycles then
                    counter := counter + 1;
                    confirm_sgl <= '0';
                elsif counter = debounce_cycles then
                    already_pressed := '1';
                    confirm_sgl <= '1';
                    counter := 1;
                else
                    confirm_sgl <= '0';
                    counter := 1;
                end if;
            elsif already_pressed = '1' and confirm_btn = '1' then
                --if counter < 3 then
                --    counter := counter + 1;
                --elsif counter = 3 then
                    confirm_sgl <= '0';
                --    counter := 1;
                --end if;
            else
                already_pressed := '0';
                confirm_sgl <= '0';
                counter := 1;
            end if;
        end if;
    end process;
    
    reset_checker : process (clock, reset_btn)
        variable counter : positive := 1;
    begin
        if rising_edge(clock) then
            if reset_btn = '0' then -- CPU Reset button is inverted
                if counter < (debounce_cycles * 10) then
                    counter := counter + 1;
                elsif counter = (debounce_cycles * 10) then
                    reset_sgl <= '1';
                    counter := 1;
                end if;
            else
                reset_sgl <= '0';
                counter := 1;
            end if;
        end if;
    end process;


    game : process(clock, reset_sgl, confirm_sgl, card_in, sw)
        variable pos : natural;
        variable temp : card;
        variable int_card1 : card;
        variable int_card2 : card;
        variable int_card3 : card;
        variable drawn : std_logic := '0';
        variable counter : integer := 0;
        variable beginning : std_logic := '1';
    begin
        if rising_edge(clock) then
            if reset_sgl = '1' or beginning = '1' then
                -- resetting everything
                if beginning = '1' then
                    reset <= '1';
                else
                    reset <= reset_sgl;
                end if;
                beginning := '0';
                card_out.value <= EMPTY;
                counter := 0;
                int_card1.value := EMPTY;
                int_card2.value := EMPTY;
                int_card3.value := EMPTY;
            elsif done = '1' then 
                reset <= '0';
                counter := counter + 1; -- needed to send the card for some clocks if there is no new card (2 clocks)
                if card_in /= int_card1 and card_in /= int_card2 and card_in /= int_card3 and card_in.value /= EMPTY then
                    pos := search_empty(int_card1, int_card2, int_card3);
                    case pos is
                        when 1 =>
                            int_card1 := card_in;
                        when 2 =>
                            int_card2 := card_in;
                        when 3 =>
                            int_card3 := card_in;
                        when others =>
                    end case;
                    card_out.value <= EMPTY;
                else
                    if confirm_sgl = '1' then
                        case sw is
                            when b"001" =>
                                temp := int_card1;
                                int_card1.value := EMPTY;
                            when b"010" =>
                                temp := int_card2;
                                int_card2.value := EMPTY;
                            when b"100" =>
                                temp := int_card3;
                                int_card3.value := EMPTY;
                            when others =>
                                temp.value := EMPTY;
                        end case;
                        
                        if temp.value /= EMPTY then
                            card_out <= temp;
                            counter := 0;
                        end if;
                    elsif counter = 2 then -- we reset the card after 2 clocks (2 - 0)
                        card_out.value <= EMPTY;
                        counter := 0;
                    end if;
                end if;
            end if;
            
            card1 <= int_card1;
            card2 <= int_card2;
            card3 <= int_card3;
            
        end if;
    end process;


end Behavioral;
