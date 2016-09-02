library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library briscola;
use briscola.data.all;

-- 260255 --> 18 bits max is 2 ^ 18 - 1 --> 262143

entity vga_drawer is
  port( clk : in std_logic;
        vidon: in std_logic;
        hc: in std_logic_vector(9 downto 0); --10 bits for 800
        vc: in std_logic_vector(9 downto 0); --10 bits for 525
        M: in std_logic_vector(11 downto 0); --vga colors
        player_card1 : in card;
        player_card2 : in card;
        player_card3 : in card;
        player_played_card : in card;
        ai_played_card : in card;
        briscola : in card;
        n_turns : in integer;
        ai_points : in integer;
        player_points : in integer;
        turn_in : in std_logic; -- 0 player 1 ai
        difficulty : in std_logic;
        
        rom_address18: out std_logic_vector(17 downto 0); --to address rom of 253380 cells
        red: out std_logic_vector(3 downto 0);
        green: out std_logic_vector(3 downto 0);
        blue: out std_logic_vector(3 downto 0);
        done : out std_logic
      );
end vga_drawer;

architecture main of vga_drawer is
    constant hbp: std_logic_vector(9 downto 0) :="0010010000"; --144 horizontal back porch and sync
    constant vbp: std_logic_vector(9 downto 0) :="0000011111"; --31 vertical back porch and sync
    constant w : integer := 55; --width figure
    constant h : integer := 101; --height figure
    signal coord : point; -- coordinates in visible area
    signal spriteon : std_logic := '0';
    signal finalrow,finalcol: std_logic:='0';
    signal col: integer := 0; 
    signal row: integer := 0;
    signal counter: integer :=0;
    signal pos : pos_type := NONE;
    signal pos_mem : pos_type := NONE;
    signal n_cards : integer;
begin  
--   --evaluate the constant for animation
--   process(clk, col, row, finalcol, finalrow)
--   begin
--    if rising_edge(clk) then
--        if((finalrow='0' or finalcol= '0')) then   --if card didn't reach final position
--            done <= '0';
--            counter<=counter+1;
--            if(counter=480 / 6 * 10000)then  --magic number...
--                counter<=0;
--                if(320-(2+col)>0)then  --320=final x, 2=initial x
--                        col<=col+1;
--                elsif(320 -(2+col)<0)then
--                       col<=col-1;
--                else 
--                       finalcol<='1';
--                end if;
                
--                if(240-(10+row)>0)then  --240 final y, 10=initial y
--                            row<=row+1;
--                elsif(240 -(10+row)<0)then
--                           row<=row-1;
--                else 
--                           finalrow<='1';
--                end if;
--             end if;
--         else
--            done <= '1';
--        end if;
--    end if;
--   end process;
   
    
--    --enable sprite video out when within the sprite region
--    spriteon <= '1' when (
--                          (((xpix > 2+col) and (xpix <=2+w+col)) and ((ypix >= 10+row) and (ypix < 10+h+row))) --card animated
--                            or (((xpix > 320) and (xpix <=320+w)) and ((ypix >= 100) and (ypix < 100+h))) --card in fixed position
--                            )else '0';
   
--    process(clk, xpix, ypix)
--    variable rom_addr1, rom_addr2: std_logic_vector(15 downto 0);
--    variable rom_addr18 : std_logic_vector(17 downto 0);
--    begin
--          if rising_edge(clk) then
--              if( (((xpix >= 0+col) and (xpix < 0+w+col)) and ((ypix >= 10+row) and (ypix < 10+h+row))))then --X POSITION 3 PIXELS BEFORE SPRITEON
--                    xmem<=xpix-0-col;
--                    ymem<=ypix-10-row;
--                    rom_addr18:="110110001111111000"; ---add 55x101x40 for back card
--                  elsif(((xpix >= 318) and (xpix <318+w)) and ((ypix >= 100) and (ypix < 100+h)))then
--                    xmem<=xpix-318;
--                    ymem<=ypix-100;
--                    rom_addr18 :="110110001111111000"; ---add 55x101x40
                 
--                 end if;
--               rom_addr1 :=("0" & ymem & "00000")+("00" & ymem &"0000")+("0000"& ymem & "00")+("00000"& ymem & "0")+("000000"& ymem); --y*55  
--               rom_addr2 := rom_addr1 + ("000000" & xmem);      --y*55+x
--              rom_address18 <= rom_addr18+("00" & rom_addr2);
--         end if;
--    end process;

    init : process(clk, vc, hc)
        variable x, y : integer;
    begin
        if rising_edge(clk) then
            x := to_integer(unsigned(hc - hbp));
            y := to_integer(unsigned(vc - vbp));
            coord <= (x => x, y => y);
            pos <= is_on_image_pos((x => x, y => y));
            pos_mem <= is_on_image_pos((x => x + mem_lag, y => y));
            if 40 - (n_turns - 1) * 2 - 6 < 0 then
                n_cards <= 0;
            else
                n_cards <= 40 - (n_turns - 1) * 2 - 6;
            end if;
        end if;
    end process;

    done_proc : process(clk)
        variable counter : integer := 1;
    begin
        if rising_edge(clk) then
            if player_played_card.value /= EMPTY and ai_played_card.value /= EMPTY then
                if counter < (debounce_cycles_def * 5) then
                    counter := counter + 1;
                    done <= '0';
                else
                    done <= '1';
                end if;
            else
                done <= '1';
                counter := 1;
            end if;
        end if;
    end process;

    sprite : process(clk, coord)
    begin
        if rising_edge(clk) then
            if pos /= NONE then
                if n_turns < 10 and pos = TURN_DIGIT1 then
                    spriteon <= '0';
                elsif n_turns = 21 and (pos = TURN_DIGIT1 or pos = TURN_DIGIT2) then
                    spriteon <= '0';
                elsif pos = TURN then
                    spriteon <= '0';
                elsif (ai_points = 0 and player_points = 0) and (pos = FINAL or pos = RES_PL_DGT1 or pos =  RES_PL_DGT2 or pos = RES_PL_DGT3 or pos = RES_AI_DGT1 or pos = RES_AI_DGT2 or pos = RES_AI_DGT3) then
                    spriteon <= '0';
                elsif pos = RES_PL_DGT1 and player_points < 100 then
                    spriteon <= '0';
                elsif pos = RES_PL_DGT2 and player_points < 10 then
                    spriteon <= '0';
                elsif pos = RES_AI_DGT1 and ai_points < 100 then
                    spriteon <= '0';
                elsif pos = RES_AI_DGT2 and ai_points < 10 then
                    spriteon <= '0';
                elsif (n_turns > 17) and (pos = BRISCOLA_VGA or pos = DECK_VGA) then
                    spriteon <= '0';
                elsif pos = AI_CARD1 and (n_turns > 18 or ai_played_card.value /= EMPTY) then
                    spriteon <= '0';
                elsif pos = AI_CARD2 and (n_turns > 19 or (n_turns = 19 and ai_played_card.value /= EMPTY)) then
                    spriteon <= '0';
                elsif pos = AI_CARD3 and (n_turns > 20 or (n_turns = 20 and ai_played_card.value /= EMPTY)) then
                    spriteon <= '0';
                elsif pos = PLAYER_CARD1_VGA and player_card1.value = EMPTY then
                    spriteon <= '0';
                elsif pos = PLAYER_CARD2_VGA and player_card2.value = EMPTY then
                    spriteon <= '0';
                elsif pos = PLAYER_CARD3_VGA and player_card3.value = EMPTY  then
                    spriteon <= '0';
                elsif pos = PLAYED_CARD_PLAYER and player_played_card.value = EMPTY  then
                    spriteon <= '0';
                elsif pos = PLAYED_CARD_AI and ai_played_card.value = EMPTY  then
                    spriteon <= '0';
                elsif pos = BRISCOLA_VGA and briscola.value = EMPTY  then
                    spriteon <= '0';
                elsif pos = N_CARDS_DIGIT1 and n_cards < 10 then
                    spriteon <= '0';
                elsif pos = N_CARDS_DIGIT2 and n_cards = 0 then
                    spriteon <= '0';
                else
                    spriteon <= '1';
                end if;
            else
                spriteon <= '0';
            end if;
        end if;
    end process;
    
    mem : process(clk, coord)
        variable temp_addr : integer;
    begin
        if rising_edge(clk) then
            case pos_mem is
                when N_TURNS_VGA =>
                    temp_addr := offset_mem_addr(coord, positions(0), dimensions(0));
                    if n_turns = 21 then
                        temp_addr := temp_addr + 260255 - 95 * 25;
                    else
                        temp_addr := temp_addr + 253380 - 95 * 25;
                    end if;
                when TURN_DIGIT1 =>
                    if n_turns > 9 then
                        temp_addr := digit_mem_addr(n_turns / 10) + offset_mem_addr(coord, positions(1), dimensions(1));
                    end if;
                when TURN_DIGIT2 =>
                    temp_addr := digit_mem_addr(n_turns mod 10) + offset_mem_addr(coord, positions(2), dimensions(2));
                when AI_CARD1 =>
                    temp_addr := 55 * 101 * 40 + offset_mem_addr(coord, positions(3), dimensions(3));
                when AI_CARD2 =>
                    temp_addr := 55 * 101 * 40 + offset_mem_addr(coord, positions(4), dimensions(4));
                when AI_CARD3 =>
                    temp_addr := 55 * 101 * 40 + offset_mem_addr(coord, positions(5), dimensions(5));
                when TURN =>
                    temp_addr := 55 * 101 * 41 + 15 * 25 * 10 + offset_mem_addr(coord, positions(6), dimensions(6));
                    if turn_in = '0' then
                        temp_addr := temp_addr + 150 * 25;
                    end if;
                when DECK_VGA =>
                    temp_addr := 55 * 101 * 40 + offset_mem_addr(coord, positions(7), dimensions(7));
                when BRISCOLA_VGA =>
                    temp_addr := card_mem_addr(briscola) + offset_mem_addr(coord, positions(8), dimensions(8));
                when PLAYED_CARD_AI =>
                    temp_addr := card_mem_addr(ai_played_card) + offset_mem_addr(coord, positions(9), dimensions(9));
                when PLAYED_CARD_PLAYER =>
                    temp_addr := card_mem_addr(player_played_card) + offset_mem_addr(coord, positions(10), dimensions(10));
                when FINAL =>
                    temp_addr := 55 * 101 * 41 + 15 * 25 * 10 + 150 * 25 * 2 + offset_mem_addr(coord, positions(11), dimensions(11));
                    if ai_points > player_points then
                        temp_addr := temp_addr + 160 * 25;
                    elsif ai_points < player_points then
                        temp_addr := temp_addr + 160 * 25 * 2;
                    end if;
                when RES_PL_DGT1 =>
                    temp_addr := digit_mem_addr(player_points / 100) + offset_mem_addr(coord, positions(12), dimensions(12));
                when RES_PL_DGT2 =>
                    temp_addr := digit_mem_addr((player_points / 10) mod 10) + offset_mem_addr(coord, positions(13), dimensions(13));
                when RES_PL_DGT3 =>
                    temp_addr := digit_mem_addr(player_points mod 10) + offset_mem_addr(coord, positions(14), dimensions(14));
                when RES_AI_DGT1 =>
                    temp_addr := digit_mem_addr(ai_points / 100) + offset_mem_addr(coord, positions(15), dimensions(15));
                when RES_AI_DGT2 =>
                    temp_addr := digit_mem_addr((ai_points / 10) mod 10) + offset_mem_addr(coord, positions(16), dimensions(16));
                when RES_AI_DGT3 =>
                    temp_addr := digit_mem_addr(ai_points mod 10) + offset_mem_addr(coord, positions(17), dimensions(17));
                when PLAYER_CARD3_VGA =>
                    temp_addr := card_mem_addr(player_card3) + offset_mem_addr(coord, positions(18), dimensions(18));
                when PLAYER_CARD2_VGA =>
                    temp_addr := card_mem_addr(player_card2) + offset_mem_addr(coord, positions(19), dimensions(19));
                when PLAYER_CARD1_VGA =>
                    temp_addr := card_mem_addr(player_card1) + offset_mem_addr(coord, positions(20), dimensions(20));
                when N_CARDS_DIGIT1 =>
                    temp_addr := digit_mem_addr(n_cards / 10) + offset_mem_addr(coord, positions(21), dimensions(21));
                when N_CARDS_DIGIT2 =>
                    temp_addr := digit_mem_addr(n_cards mod 10) + offset_mem_addr(coord, positions(22), dimensions(22));
                when DIFFICULTY_VGA =>
                    temp_addr := 257880 + offset_mem_addr(coord, positions(23), dimensions(23));
                    if difficulty = '0' then
                        temp_addr := temp_addr - 90 * 25;
                    else
                        temp_addr := temp_addr - 2 * 90 * 25;
                    end if;
                when others =>
                    temp_addr := 0;
            end case;
            rom_address18 <= std_logic_vector(to_unsigned(temp_addr, 18));
        end if;
    end process;
    
    --assign output for VGA
    output : process(clk, spriteon, vidon, M)
    begin
        if rising_edge(clk) then
            red <= "0000";
            green <= "0000";
            blue <= "0000"; 
            if spriteon = '1' and vidon = '1' then
                    red <= M(11 downto 8);
                    green <= M(7 downto 4);
                    blue <= M(3 downto 0);
            elsif vidon = '1' then
                    red <= "0000";
                    green <= "1010";
                    blue <= "0000";
            end if;
        end if;
    end process;
end main; 
          