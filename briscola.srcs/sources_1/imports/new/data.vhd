library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- 253380 --> 18 bits max is 2 ^ 18 - 1 --> 262143

package data is
    type shuffled_pos is array(0 to 39) of integer range -1 to 39;
    type mov_type is (NEW_PLAYER_CARD, NEW_AI_CARD, AI_PLAYED_CARD_VGA, PLAYER_PLAYED_CARD_VGA);
    type pos_type is (N_TURNS_VGA, TURN_DIGIT1, TURN_DIGIT2, AI_CARD1, AI_CARD2, AI_CARD3, TURN, DECK_VGA, BRISCOLA_VGA, PLAYED_CARD_AI, PLAYED_CARD_PLAYER, FINAL, RES_PL_DGT1, RES_PL_DGT2, RES_PL_DGT3, RES_AI_DGT1, RES_AI_DGT2, RES_AI_DGT3, PLAYER_CARD3_VGA, PLAYER_CARD2_VGA, PLAYER_CARD1_VGA, N_CARDS_DIGIT1, N_CARDS_DIGIT2, DIFFICULTY_VGA, NONE);
    type card_value is (EMPTY, ACE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, JACK, HORSE, KING, BACK);
    type card_suit is (COINS, CLUBS, SWORDS, CUPS);
    type card is
        record
            value : card_value;
            suit : card_suit;
            points : integer range 0 to 11;
        end record;
    
    type point is
        record
            x : integer range 0 to 639;
            y : integer range 0 to 479;
        end record;
    
    type deck is array(0 to 39) of card;
    type points is array(0 to 10) of integer;
    type hand is array (0 to 2) of card;
    subtype addr is std_logic_vector(17 downto 0);
    
    function search_empty(card1 : card; card2 : card; card3 : card) return integer;
    function compute_points(card1 : card; card2 : card; briscola : card) return integer;
    function card_mem_addr(card : card) return integer;
    function digit_mem_addr(digit : integer) return integer;
    function offset_mem_addr(coord : point; pos : point; dim : point) return integer;
    function is_on_image_pos(pos : point) return pos_type;
    function is_already_in_shuffle(shuffle : shuffled_pos; pos : integer) return std_logic;
    procedure init_deck(my_deck: out deck);
    
    constant debounce_cycles_def : integer;
    constant card_points : points;
    constant transition_time : integer;
    constant mem_lag : integer;
    
    type pixels is array(0 to 23) of point;
    constant positions : pixels;
    constant dimensions : pixels;
    
    constant card_width : integer;
    constant card_height : integer;
    
    type music_type is array(0 to 3, 0 to 38, 0 to 1) of integer;
    constant music : music_type;
    
    type musiclength_type is array(0 to 3) of integer;
    constant musiclength : musiclength_type;

end package;

package body data is
    constant musiclength : musiclength_type := (34, 39, 14, 18);
    
    -- (clockfrequency/freq/2, freq*2*duration)
    -- clockfrequency is 25.175 MHz in our case, because of VGA
    constant music : music_type := ( -- music 0 : background
--                                    ((48044, 393/2), -- freq 262 Hz duration 0.75 sec
--                                     (38144, 495/2), -- freq 330 Hz duration 0.75 sec
--                                     (34020, 555/2), -- freq 370 Hz duration 0.75 sec
--                                     (28608, 660/2), -- freq 440 Hz duration 0.75 sec
--                                     (32111, 588/2), -- freq 392 Hz duration 0.75 sec
--                                     (38144, 495/2), -- freq 330 Hz duration 0.75 sec
--                                     (48044, 393/2), -- freq 262 Hz duration 0.75 sec
--                                     (28608, 555/2), -- freq 440 Hz duration 0.63 sec
--                                     (34020, 555/2), -- freq 370 Hz duration 0.75 sec
--                                     (0, 500000),
--                                     (34020, 555/2), -- freq 370 Hz duration 0.75 sec
--                                     (0, 500000),
--                                     (34020, 555/2), -- freq 370 Hz duration 0.75 sec
--                                     (32111, 588/2), -- freq 392 Hz duration 0.75 sec
--                                     (48044, 393/2), -- freq 262 Hz duration 0.75 sec
--                                     (0, 500000),
--                                     (48044, 393/2), -- freq 262 Hz duration 0.75 sec
--                                     (0, 500000),
--                                     (48044, 393/2), -- freq 262 Hz duration 0.75 sec
--                                     (0, 500000),
--                                     (48044, 393/2), -- freq 262 Hz duration 0.75 sec
--                                     (0, 10000000)),
                                    ((48044,79),
                                     (0, 500000),
                                     (48044,79),
                                     (28608,660),
                                     (38144,99),
                                     (32111,118),
                                     (36067,105),
                                     (42815,353),
                                     (0, 500000),
                                     (42815,88),
                                     (0, 500000),
                                     (42815,88),
                                     (27012,699),
                                     (32111,118),
                                     (28608,132),
                                     (32111,118),
                                     (38144,594),
                                     (0, 500000),
                                     (38144,99),
                                     (0, 500000),
                                     (38144,99),
                                     (24068,785),
                                     (28608,132),
                                     (27012,140),
                                     (24068,157),
                                     (21444,1057),
                                     (36067,105),
                                     (32111,118),
                                     (28608,660),
                                     (38144,99),
                                     (36067,105),
                                     (32111,118),
                                     (36067,628),
                                     (0,7552500),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0)),
                                     
                                     -- music 1 : player victory
                                    ((21432, 410),
                                     (28608, 154),
                                     (21432, 205),
                                     (19094, 461),     
                                     (25487, 173),
                                     (19094, 231), 
                                     (17010, 259), 
                                     (16056, 274),
                                     (14304, 616),    
                                     (19094, 230), 
                                     (17010, 259),
                                     (16055, 549),    
                                     
                                     (21432, 410),
                                     (28608, 154),
                                     (21432, 205),
                                     (19094, 461),     
                                     (25487, 173),
                                     (19094, 231), 
                                     (17010, 259), 
                                     (16056, 274),
                                     (14304, 616),    
                                     (18034, 244), 
                                     (16055, 274),
                                     (14304, 616),
                                     
                                     (21432, 410),
                                     (28608, 154),
                                     (21432, 205),
                                     (19094, 461),     
                                     (25487, 173),
                                     (19094, 231), 
                                     
                                     (18034, 489),
                                     (24068, 183),
                                     (18034, 244),
                                     (16055, 274),
                                     (21444, 205),
                                     (16055, 549),
                                     (17010, 2072),
                                     (19101, 1845),
                                     (0, 7552500)),
                                     
                                     -- music 2 : ai victory -- DONE
                                    ((25487, 148),    --freq 392 Hz duration 0.3 sec
                                     (18022, 210),    --freq 587 Hz duration 0.3 sec
                                     (0, 7552500),  --freq 1976 Hz duration 0.3 sec
                                     (18022, 210),    --freq 587 Hz duration 0.3 sec
                                     (0, 500000),
                                     (18022, 210 * 2 / 3),--freq 587 Hz duration 0.3 sec
                                     (19094, 198 * 2 / 3),--freq 523 Hz duration 0.3 sec
                                     (21432, 176 * 2 / 3),--freq 988 Hz duration 0.3 sec
                                     (24056, 157),    --freq 392 Hz duration 0.3 sec
                                     (38187, 99),    --freq 330 Hz duration 0.3 sec
                                     (0, 7552500),  --freq 1976 Hz duration 0.3 sec
                                     (38187, 99),    --freq 330 Hz duration 0.3 sec
                                     (48112, 78),    --freq 262 Hz duration 0.3 sec
                                     (0, 100000000),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0)),
                                     
                                     -- music 3 : draw -- DONE
                                    ((71928, 123),   --freq 175 Hz duration 0.35 sec
                                     (0, 500000),
                                     (71928, 123),   --freq 175 Hz duration 0.35 sec
                                     (60517, 146),   --freq 208 Hz duration 0.35 sec
                                     (64222, 137),   --freq 196 Hz duration 0.35 sec
                                     (57216, 154),   --freq 220 Hz duration 0.35 sec
                                     (0, 500000),
                                     (57216, 154),   --freq 220 Hz duration 0.35 sec
                                     (48044, 183),   --freq 262 Hz duration 0.35 sec
                                     (48044, 183/2), --freq 262 Hz duration 0.35 sec
                                     (57216, 154/2), --freq 220 Hz duration 0.35 sec
                                     (71928, 123/2), --freq 175 Hz duration 0.35 sec
                                     (42815, 206/2), --freq 294 Hz duration 0.35 sec
                                     (71928, 123),   --freq 175 Hz duration 0.35 sec
                                     (60517, 146/2), --freq 208 Hz duration 0.35 sec
                                     (38144, 231/2), --freq 330 Hz duration 0.35 sec
                                     (64222, 137),   --freq 196 Hz duration 0.35 sec
                                     (0, 10000000),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0),
                                     (0, 0))
                                    );

    constant mem_lag : integer := 1; -- clock cycles of lagging memory
    constant card_width : integer := 55;
    constant card_height : integer := 101;
    constant dimensions : pixels := ((x => 95, y => 25), -- # of turns -- 0
                                     (x => 15, y => 25), -- first turn digit -- 1
                                     (x => 15, y => 25), -- second turn digit -- 2   
                                     (x => 55, y => 101), -- ai card (back) -- 3
                                     (x => 55, y => 101), -- ai card (back) -- 4
                                     (x => 55, y => 101), -- ai card (back) -- 5
                                     (x => 150, y => 25), -- ai/player turn -- 6
                                     (x => 55, y => 101), -- deck (back) -- 7
                                     (x => 55, y => 101), -- briscola -- 8
                                     (x => 55, y => 101), -- ai played card -- 9
                                     (x => 55, y => 101), -- player played card -- 10
                                     (x => 160, y => 25), -- you win/you lose -- 11
                                     (x => 15, y => 25), -- first digit for player result -- 12
                                     (x => 15, y => 25), -- second digit for player result -- 13
                                     (x => 15, y => 25), -- third digit for player result -- 14
                                     (x => 15, y => 25), -- first digit for ai result -- 15
                                     (x => 15, y => 25), -- second digit for ai result -- 16
                                     (x => 15, y => 25), -- third digit for ai result -- 17
                                     (x => 55, y => 101), -- player card 3 -- 18
                                     (x => 55, y => 101), -- player card 2 -- 19
                                     (x => 55, y => 101), -- player card 1 -- 20
                                     (x => 15, y => 25), -- first digit for remaining cards -- 21
                                     (x => 15, y => 25), -- second digit for remaining cards -- 22
                                     (x => 90, y => 25)); -- ai difficulty -- 23
    constant positions : pixels := ((x => 40, y => 40), -- # of turns
                                    (x => 150, y => 40), -- first turn digit
                                    (x => 165, y => 40), -- second turn digit
                                    (x => 200, y => 40), -- ai card (back)
                                    (x => 300, y => 40), -- ai card (back)
                                    (x => 400, y => 40), -- ai card (back)
                                    (x => 480, y => 40), -- ai/player turn
                                    (x => 55, y => 170), -- deck (back)
                                    (x => 120, y => 170), -- briscola
                                    (x => 240, y => 170), -- ai played card
                                    (x => 350, y => 170), -- player played card
                                    (x => 450, y => 170), -- you win/you lose
                                    (x => 500, y => 220), -- first digit for player result
                                    (x => 515, y => 220), -- second digit for player result
                                    (x => 530, y => 220), -- third digit for player result
                                    (x => 575, y => 220), -- first digit for ai result
                                    (x => 590, y => 220), -- second digit for ai result
                                    (x => 605, y => 220), -- third digit for ai result
                                    (x => 200, y => 300), -- player card 3
                                    (x => 300, y => 300), -- player card 2
                                    (x => 400, y => 300), -- player card 1
                                    (x => 100, y => 300), -- first digit for remaining cards
                                    (x => 115, y => 300), -- second digit for remaining cards
                                    (x => 500, y => 350)); -- ai difficulty
    constant transition_time : integer := 10000000; -- 1 sec for example, depends on clock
    constant debounce_cycles_def : integer := 10000000; -- 0.1 sec with 100 MHz -- 0.1 * 100 / 21.175 with 21.175 MHz
    constant card_points : points := (11, 0, 10, 0, 0, 0, 0, 2, 3, 4, -1);
    
    
    function card_mem_addr(card : card) return integer is
        variable temp_addr : integer;
    begin
        case (card.value) is
            when ACE =>
                temp_addr := 0;
            when TWO =>
                temp_addr := 55 * 101; -- 5555 = 55 * 101 dimensions of a single card
            when THREE =>
                temp_addr := 55 * 101 * 2;
            when FOUR =>
                temp_addr := 55 * 101 * 3;
            when FIVE =>
                temp_addr := 55 * 101 * 4;
            when SIX =>
                temp_addr := 55 * 101 * 5;
            when SEVEN =>
                temp_addr := 55 * 101 * 6;
            when JACK =>
                temp_addr := 55 * 101 * 7;
            when HORSE =>
                temp_addr := 55 * 101 * 8;
            when KING =>
                temp_addr := 55 * 101 * 9;
            when others =>
                temp_addr := 0;
        end case;
        
        case (card.suit) is
            when CUPS =>
                temp_addr := temp_addr;
            when COINS =>
                temp_addr := temp_addr + 55 * 101 * 10;
            when SWORDS =>
                temp_addr := temp_addr + 55 * 101 * 20;
            when CLUBS =>
                temp_addr := temp_addr + 55 * 101 * 30;
        end case;
        
        if card.value = BACK then
            temp_addr := 55 * 101 * 40;
        end if;
        
        return temp_addr;
    end function;
    
    
    function digit_mem_addr(digit : integer) return integer is
        variable temp_addr : integer := 55 * 101 * 41;
    begin
        case (digit) is
            when 0 =>
                temp_addr := temp_addr;
            when 1 =>
                temp_addr := temp_addr + 15 * 25;
            when 2 =>
                temp_addr := temp_addr + 15 * 25 * 2;
            when 3 =>
                temp_addr := temp_addr + 15 * 25 * 3;
            when 4 =>
                temp_addr := temp_addr + 15 * 25 * 4;
            when 5 =>
                temp_addr := temp_addr + 15 * 25 * 5;
            when 6 =>
                temp_addr := temp_addr + 15 * 25 * 6;
            when 7 =>
                temp_addr := temp_addr + 15 * 25 * 7;
            when 8 =>
                temp_addr := temp_addr + 15 * 25 * 8;
            when 9 =>
                temp_addr := temp_addr + 15 * 25 * 9;
            when others =>
                temp_addr := temp_addr;
        end case;   
    
        return temp_addr;
    end function;
    
    
    function offset_mem_addr(coord : point; pos : point; dim : point) return integer is
        variable temp_addr : integer := 0;
    begin
        if ((coord.x >= (pos.x - mem_lag)) and (coord.x < (pos.x + dim.x - mem_lag))) and ((coord.y >= (pos.y)) and (coord.y < (pos.y + dim.y))) then
            temp_addr := (coord.y - pos.y) * dim.x + (coord.x - pos.x + mem_lag);
        end if;
        
        return temp_addr;
    end function;
   
   
    function is_on_image_pos(pos : point) return pos_type is
        variable flag : pos_type := NONE;
    begin
        if ((pos.x >= (positions(0).x)) and (pos.x < (positions(0).x + dimensions(0).x))) and ((pos.y >= (positions(0).y)) and (pos.y < (positions(0).y + dimensions(0).y))) then
            flag := pos_type'val(0);
        elsif ((pos.x >= (positions(1).x)) and (pos.x < (positions(1).x + dimensions(1).x))) and ((pos.y >= (positions(1).y)) and (pos.y < (positions(1).y + dimensions(1).y))) then
            flag := pos_type'val(1);
        elsif ((pos.x >= (positions(2).x)) and (pos.x < (positions(2).x + dimensions(2).x))) and ((pos.y >= (positions(2).y)) and (pos.y < (positions(2).y + dimensions(2).y))) then
            flag := pos_type'val(2);
        elsif ((pos.x >= (positions(3).x)) and (pos.x < (positions(3).x + dimensions(3).x))) and ((pos.y >= (positions(3).y)) and (pos.y < (positions(3).y + dimensions(3).y))) then
            flag := pos_type'val(3);
        elsif ((pos.x >= (positions(4).x)) and (pos.x < (positions(4).x + dimensions(4).x))) and ((pos.y >= (positions(4).y)) and (pos.y < (positions(4).y + dimensions(4).y))) then
            flag := pos_type'val(4);
        elsif ((pos.x >= (positions(5).x)) and (pos.x < (positions(5).x + dimensions(5).x))) and ((pos.y >= (positions(5).y)) and (pos.y < (positions(5).y + dimensions(5).y))) then
            flag := pos_type'val(5);
        elsif ((pos.x >= (positions(6).x)) and (pos.x < (positions(6).x + dimensions(6).x))) and ((pos.y >= (positions(6).y)) and (pos.y < (positions(6).y + dimensions(6).y))) then
            flag := pos_type'val(6);
        elsif ((pos.x >= (positions(7).x)) and (pos.x < (positions(7).x + dimensions(7).x))) and ((pos.y >= (positions(7).y)) and (pos.y < (positions(7).y + dimensions(7).y))) then
            flag := pos_type'val(7);
        elsif ((pos.x >= (positions(8).x)) and (pos.x < (positions(8).x + dimensions(8).x))) and ((pos.y >= (positions(8).y)) and (pos.y < (positions(8).y + dimensions(8).y))) then
            flag := pos_type'val(8);
        elsif ((pos.x >= (positions(9).x)) and (pos.x < (positions(9).x + dimensions(9).x))) and ((pos.y >= (positions(9).y)) and (pos.y < (positions(9).y + dimensions(9).y))) then
            flag := pos_type'val(9);
        elsif ((pos.x >= (positions(10).x)) and (pos.x < (positions(10).x + dimensions(10).x))) and ((pos.y >= (positions(10).y)) and (pos.y < (positions(10).y + dimensions(10).y))) then
            flag := pos_type'val(10);
        elsif ((pos.x >= (positions(11).x)) and (pos.x < (positions(11).x + dimensions(11).x))) and ((pos.y >= (positions(11).y)) and (pos.y < (positions(11).y + dimensions(11).y))) then
            flag := pos_type'val(11);
        elsif ((pos.x >= (positions(12).x)) and (pos.x < (positions(12).x + dimensions(12).x))) and ((pos.y >= (positions(12).y)) and (pos.y < (positions(12).y + dimensions(12).y))) then
            flag := pos_type'val(12);
        elsif ((pos.x >= (positions(13).x)) and (pos.x < (positions(13).x + dimensions(13).x))) and ((pos.y >= (positions(13).y)) and (pos.y < (positions(13).y + dimensions(13).y))) then
            flag := pos_type'val(13);
        elsif ((pos.x >= (positions(14).x)) and (pos.x < (positions(14).x + dimensions(14).x))) and ((pos.y >= (positions(14).y)) and (pos.y < (positions(14).y + dimensions(14).y))) then
            flag := pos_type'val(14);
        elsif ((pos.x >= (positions(15).x)) and (pos.x < (positions(15).x + dimensions(15).x))) and ((pos.y >= (positions(15).y)) and (pos.y < (positions(15).y + dimensions(15).y))) then
            flag := pos_type'val(15);
        elsif ((pos.x >= (positions(16).x)) and (pos.x < (positions(16).x + dimensions(16).x))) and ((pos.y >= (positions(16).y)) and (pos.y < (positions(16).y + dimensions(16).y))) then
            flag := pos_type'val(16);
        elsif ((pos.x >= (positions(17).x)) and (pos.x < (positions(17).x + dimensions(17).x))) and ((pos.y >= (positions(17).y)) and (pos.y < (positions(17).y + dimensions(17).y))) then
            flag := pos_type'val(17);
        elsif ((pos.x >= (positions(18).x)) and (pos.x < (positions(18).x + dimensions(18).x))) and ((pos.y >= (positions(18).y)) and (pos.y < (positions(18).y + dimensions(18).y))) then
            flag := pos_type'val(18);
        elsif ((pos.x >= (positions(19).x)) and (pos.x < (positions(19).x + dimensions(19).x))) and ((pos.y >= (positions(19).y)) and (pos.y < (positions(19).y + dimensions(19).y))) then
            flag := pos_type'val(19);
        elsif ((pos.x >= (positions(20).x)) and (pos.x < (positions(20).x + dimensions(20).x))) and ((pos.y >= (positions(20).y)) and (pos.y < (positions(20).y + dimensions(20).y))) then
            flag := pos_type'val(20);
        elsif ((pos.x >= (positions(21).x)) and (pos.x < (positions(21).x + dimensions(21).x))) and ((pos.y >= (positions(21).y)) and (pos.y < (positions(21).y + dimensions(21).y))) then
            flag := pos_type'val(21);
        elsif ((pos.x >= (positions(22).x)) and (pos.x < (positions(22).x + dimensions(22).x))) and ((pos.y >= (positions(22).y)) and (pos.y < (positions(22).y + dimensions(22).y))) then
            flag := pos_type'val(22);
        elsif ((pos.x >= (positions(23).x)) and (pos.x < (positions(23).x + dimensions(23).x))) and ((pos.y >= (positions(23).y)) and (pos.y < (positions(23).y + dimensions(23).y))) then
            flag := pos_type'val(23);
        else
            flag := NONE;
        end if;
        
        return flag;
    end function;
   
   
    function search_empty(card1 : card; card2 : card; card3 : card) return integer is
        variable result : integer := 0;
    begin
        if card1.value = EMPTY then
            result := 1;
        elsif card2.value = EMPTY then
            result := 2;
        elsif card3.value = EMPTY then
            result := 3;
        end if;
        
        return result;
    end function;
   
    
    function compute_points(card1 : card; card2 : card; briscola : card) return integer is
        variable result : integer := card1.points + card2.points; -- pos when first wins, neg when second
    begin
        -- We invert the sign, thus the taker, when the other has briscola or higher value with the same suit, assuming the frst to play is the first card
        if (briscola.suit = card2.suit and briscola.suit /= card1.suit) or (card1.suit = card2.suit and ((card2.points > card1.points) or (card2.points = card1.points and card2.value > card1.value))) then
            result := -result;
            if result = 0 then
                result := -40;
             end if;
        end if;
        return result;
    end function;
    
    function is_already_in_shuffle(shuffle : shuffled_pos; pos : integer) return std_logic is
        variable found : std_logic := '0';
    begin
        if shuffle(0) = pos then
            found := '1';
        elsif shuffle(1) = pos then
            found := '1';
        elsif shuffle(2) = pos then
            found := '1';
        elsif shuffle(3) = pos then
            found := '1';
        elsif shuffle(4) = pos then
            found := '1';
        elsif shuffle(5) = pos then
            found := '1';
        elsif shuffle(6) = pos then
            found := '1';
        elsif shuffle(7) = pos then
            found := '1';
        elsif shuffle(8) = pos then
            found := '1';
        elsif shuffle(9) = pos then
            found := '1';
        elsif shuffle(10) = pos then
            found := '1';
        elsif shuffle(11) = pos then
            found := '1';
        elsif shuffle(12) = pos then
            found := '1';
        elsif shuffle(13) = pos then
            found := '1';
        elsif shuffle(14) = pos then
            found := '1';
        elsif shuffle(15) = pos then
            found := '1';
        elsif shuffle(16) = pos then
            found := '1';
        elsif shuffle(17) = pos then
            found := '1';
        elsif shuffle(18) = pos then
            found := '1';
        elsif shuffle(19) = pos then
            found := '1';
        elsif shuffle(20) = pos then
            found := '1';
        elsif shuffle(21) = pos then
            found := '1';
        elsif shuffle(22) = pos then
            found := '1';
        elsif shuffle(23) = pos then
            found := '1';
        elsif shuffle(24) = pos then
            found := '1';
        elsif shuffle(25) = pos then
            found := '1';
        elsif shuffle(26) = pos then
            found := '1';
        elsif shuffle(27) = pos then
            found := '1';
        elsif shuffle(28) = pos then
            found := '1';
        elsif shuffle(29) = pos then
            found := '1';
        elsif shuffle(30) = pos then
            found := '1';
        elsif shuffle(31) = pos then
            found := '1';
        elsif shuffle(32) = pos then
            found := '1';
        elsif shuffle(33) = pos then
            found := '1';
        elsif shuffle(34) = pos then
            found := '1';
        elsif shuffle(35) = pos then
            found := '1';
        elsif shuffle(36) = pos then
            found := '1';
        elsif shuffle(37) = pos then
            found := '1';
        elsif shuffle(38) = pos then
            found := '1';
        elsif shuffle(39) = pos then
            found := '1';
        end if;
        
        return found;
    end function;
    
    procedure init_deck(my_deck: out deck) is
    begin
        for i in 0 to 39 loop
            my_deck(i).value := card_value'val(i mod 10 + 1);
            my_deck(i).suit := card_suit'val(i / 10);
            my_deck(i).points := card_points(i mod 10);
        end loop;
    end procedure;
end package body;
