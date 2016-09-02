library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library briscola;
use briscola.data.all;

entity Server is
    generic (max_turns : integer := 20);
    port (clock : in std_logic; -- clock
          player_card : in card; -- card played by the user
          ai_card : in card; -- card played by the ai
          reset : in std_logic; -- reset signal coming from player
          done : in std_logic; -- signal used to check whether the VGA has finished drawing
          
          player_played_card : out card; -- card played by user in a fixed register for the vga
          ai_played_card : out card; -- card played by ai in a fixed register for the vga
          n_turns : out integer; -- number of current turn
          ai_points_vga : out integer; -- points made by the ai, sent to the vga at the end of the match
          player_points_vga : out integer; -- points made by the user, sent to the vga at the end of the match
          
          music_index : out integer;
          
          player_new_card : out card; -- new card given to the player at the beginning of a new turn
          ai_new_card : out card; -- new card given to the ai at the beginning of a new turn
          briscola : out card; -- briscola, fixed register at the beginning of the match
          turn : out std_logic); -- whose turn is, '0' for player, '1' for ai, used as an enable for the ai
end Server;

architecture Behavioral of Server is
    
    signal pos : std_logic_vector(5 downto 0); -- signal used to get the random number from the generator, and use it as position inside the deck
    signal enable : std_logic := '0'; -- enable for the random number generator, only when needed (shuffling at beginning)
    signal seed : std_logic_vector (31 downto 0) := x"80000000"; -- seed for the random number generator

    component PRNG
        generic (width : integer := 6); -- width of the generated number
        port (clk : in std_logic; -- clock
              seed : in std_logic_vector (width-1 downto 0); -- seed for generating numbers
              random_num : out std_logic_vector (width-1 downto 0); -- generated number
              enable : in std_logic); -- enable signal
    end component;

begin
    
    random_comp : PRNG
        generic map (width => 6)
        port map (clk => clock, random_num => pos, enable => enable, seed => seed(31 downto 26)); -- mapping
    
    game : process(clock, reset, player_card, ai_card)
        variable shuffle : shuffled_pos := (others=> -1); -- all the positions to be used during the match
        variable my_deck : deck := (others=>(value=>EMPTY, points=>0, suit=>COINS)); -- default init values for deck, initialized one time during the first match
        variable phase : integer := 0; -- finite state machine variable, to determine the phase of the game
        variable i : integer := 0; -- generic counter
        variable card_pos : natural; -- position of the last given card
        variable first_to_play : std_logic := '1'; -- 1 AI, 0 player
        variable temp_brisc : card; -- internal briscola register, because the output signal cannot be read 
        variable turns : natural := 0; -- internal register for the number of turns
        variable take : integer; -- the point made at the end of the turn, used also to determine first_to_play for the following turn
        variable player_points : natural := 0; -- register for player points
        variable ai_points : natural := 0; -- register for ai points
        variable temp_pos : natural; -- used to set up the array of positions at the beginning of each match
        
        variable my_ai_card : card; -- register for the card played by the ai, since it is reset after 2 clock cycles
        variable my_player_card : card; -- register for the card played by the user, since it is reset after 2 clock cycles
        
        variable counter : natural range 0 to 2 := 0; -- counter used to delay the reset of different signals
        variable counter2 : std_logic := '0'; -- counter used to delay the operation of the Server because of lagging VGA signal done
    
    begin
        if rising_edge(clock) then
            if my_deck(0).value = EMPTY then
                init_deck(my_deck); -- initialize the deck for the first time, setting up all the cards
            end if;
        
            if (ai_card.value /= EMPTY) then
                my_ai_card := ai_card; -- we save the card played by the ai if it is not empty
            end if;
            
            if (player_card.value /= EMPTY and phase = 2) then -- we take the card if and only if we are in the second phase (computing points)
                my_player_card := player_card; -- we save if and only if we are waiting to compute the points
            end if;
        
            if enable = '0' then
                seed <= std_logic_vector(unsigned(seed) + b"1"); -- we update our seed only when we are not using the random number generator
            end if;
            
            if reset = '1' then -- we reset every possible variable/signal to the starting values if we receive the reset
                briscola <= (value=>EMPTY, points => 0, suit => COINS);
                player_new_card.value <= EMPTY;
                ai_new_card.value <= EMPTY;
                phase := 0;
                i := 0;
                turns := 1;
                ai_points := 0;
                player_points := 0;
                first_to_play := seed(26);
                enable <= '1';
                shuffle := (others => -1);
                counter := 0;
                counter2 := '0';
                my_player_card.value := EMPTY;
                my_ai_card.value := EMPTY;
                ai_points_vga <= 0;
                player_points_vga <= 0;
                music_index <= -1;
            elsif phase = 0 then -- shuffling
                if i < 40 then
                    temp_pos := to_integer(unsigned(pos)) mod 40;

                    if is_already_in_shuffle(shuffle, temp_pos) = '0' then -- to check already reeceived position
                        shuffle(i) := temp_pos;
                        i := i + 1;
                    end if;
                else -- if we have shuffled everything we set up for the next phase
                    phase := 1;
                    counter := 0;
                    counter2 := '0';
                    card_pos := 0;
                    briscola <= my_deck(shuffle(39));
                    temp_brisc := my_deck(shuffle(39)); -- Otherwise we cannot read from output signal
                    enable <= '0';
                end if;
            -- here counter2 is used to wait, since the done signal from the vga block lags by one cycle 
            elsif phase = 1 and done = '1' and counter2 = '1' then -- giving cards after we wait for movement completion of vga
                music_index <= 0; -- index for standard background music
                if counter = 0 then -- this counter is used to send the cards for 2 clocks, to allow AI receiving the correct card just for one time
                    if card_pos < 39 then -- the position of the first card to be given to player/AI
                        -- we choose card order depending on which one plays as first
                        if first_to_play = '0' then
                            player_new_card <= my_deck(shuffle(card_pos));
                            ai_new_card <= my_deck(shuffle(card_pos + 1));
                        else
                            player_new_card <= my_deck(shuffle(card_pos + 1));
                            ai_new_card <= my_deck(shuffle(card_pos));
                        end if;
                        card_pos := card_pos + 2;
                    end if;
                end if;
                
                counter := counter + 1; -- used to have the cards sent for some clocks for AI lagging
                counter2 := counter2 xor '1';
                
                if card_pos >= 6 and counter = 2 then -- 2 clocks
                    phase := 2;
                    counter := 0;
                    counter2 := '0';
                elsif card_pos < 6 and counter = 2 then
                    counter := 0; -- immediate reset when sending first three cards
                end if;
            elsif phase = 2 and done = '1' and counter2 = '1' then -- computing points after we wait for movement completion of vga                    
                player_new_card.value <= EMPTY; -- reset input cards when changing phase
                ai_new_card.value <= EMPTY;
                counter2 := counter2 xor '1'; -- just 1 clock of delay
                if my_player_card.value /= EMPTY and my_ai_card.value /= EMPTY then
                    turn <= '0'; -- we reset turn to avoid AI playing again
                    if counter = 1 then -- we wait to distribute these cards to the VGA
                        if first_to_play = '0' then
                            take := compute_points(my_player_card, my_ai_card, temp_brisc);
                            if take >= 0 then
                                 player_points := player_points + take;
                            elsif take < 0 then
                                if take /= -40 then
                                    ai_points := ai_points - take;
                                end if;
                                first_to_play := '1';
                            end if;
                        else
                            take := compute_points(my_ai_card, my_player_card, temp_brisc);
                            if take >= 0 then
                                ai_points := ai_points + take;
                            elsif take < 0 then
                                if take /= -40 then
                                    player_points := player_points - take;
                                end if;
                                first_to_play := '0';
                            end if;
                        end if;
                        
                        counter := 0;
                        
                        turns := turns + 1;
                        my_player_card.value := EMPTY; -- reset internal regs
                        my_ai_card.value := EMPTY;
                      
                        if turns < 21 then
                            phase := 1;
                            counter2 := '0';
                        else
                            phase := 3;
                            counter2 := '0';
                        end if;
                    elsif counter = 0 then
                        counter := counter + 1;
                    end if;
                elsif (my_ai_card.value /= EMPTY) then -- we keep the AI deactivated because player has not yet played
                    turn <= '0'; -- or we deactivate it when we receive a card
                elsif (my_player_card.value /= EMPTY and first_to_play = '0') or (my_player_card.value = EMPTY and first_to_play = '1') then
                    turn <= '1'; -- we activate it if player has played or if AI has not yet played for first, after player card disappears
                end if;
            elsif phase = 3 and done = '1' and counter2 = '1' then
                counter2 := counter2 xor '1';
                ai_points_vga <= ai_points; -- sent to the vga
                player_points_vga <= player_points;
                
                if ai_points < player_points then
                    music_index <= 1; -- player wins
                elsif ai_points > player_points then
                    music_index <= 2; -- ai wins
                else
                    music_index <= 3; -- draw
                end if;
                
            else
                counter2 := counter2 xor '1';
            end if;
            
            ai_played_card <= my_ai_card; -- send info to the vga
            player_played_card <= my_player_card;
            n_turns <= turns;
        end if;
    end process;
end Behavioral;
