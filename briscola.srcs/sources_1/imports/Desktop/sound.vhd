library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library briscola;
use briscola.data.all;

ENTITY sound IS
  PORT(
        clk: in std_logic;
        
        index : in integer;
        
        enable : in std_logic;
        volume : in std_logic;
        
        speaker: out std_logic;
        ampSD: out std_logic
  );
END sound;

ARCHITECTURE MAIN of sound IS
begin
    snd : process(clk)
        variable counterduty : integer := 0;
        variable countercycle : integer := 0;
        variable notepos : integer := 0;
        variable speakertemp : std_logic := '0';
        variable indextemp : integer := -2;
    begin
        if rising_edge(clk) then
            if indextemp = -2 or index = -1 then
                indextemp := index;
            end if;
            
            if enable = '1' and index >= 0 and index < 4 then
                ampSD <= volume ;
                if indextemp = index then
                    if countercycle < music(index, notepos, 1) then
                        if counterduty < music(index, notepos,0) then
                            counterduty := counterduty + 1;
                        else
                            countercycle := countercycle + 1;
                            counterduty := 0;
                            if music(index, notepos, 0) = 0 then
                                speaker <= '0';
                                speakertemp := '0';
                            else
                                if speakertemp = '0' then
                                    speaker <= '1';
                                    speakertemp := '1';
                                else 
                                    speaker <= '0';
                                    speakertemp := '0';
                                end if;
                            end if;
                        end if;
                    elsif notepos < musiclength(index) then -- there was <=
                        countercycle := 0;
                        counterduty := 0;
                        notepos := notepos + 1;
                    else
                        countercycle := 0;
                        counterduty := 0;
                        notepos := 0;
                    end if;
                else
                    indextemp := index;
                    countercycle := 0;
                    counterduty := 0;
                    notepos := 0;
                end if;
            else
                ampSD <= '0';
                speaker <= '0';
                speakertemp := '0';
            end if;
        end if;
   end process;
end main; 