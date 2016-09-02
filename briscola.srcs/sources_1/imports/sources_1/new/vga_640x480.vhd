library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity vgasync is 
    port (clk, clr : in std_logic;
          hsync : out std_logic;
          vsync : out std_logic;
          hc : out std_logic_vector(9 downto 0);
          vc : out std_logic_vector(9 downto 0);
          vidon : out std_logic;
          vsenable: out std_logic
          );
end vgasync;

architecture main of vgasync is

constant hpixels: std_logic_vector(9 downto 0) :="1100100000"; --800 (96+48+640+16) tot horizontal
constant vlines: std_logic_vector(9 downto 0) :="1000001101"; --525(2+29+480+10) tot vertical 
constant hbp: std_logic_vector(9 downto 0) :="0010010000"; --144 (96+48) horizontal back porch and sync
constant hfp: std_logic_vector(9 downto 0) :="1100010000"; --784 (800-16) horizontal front porch
constant vbp: std_logic_vector(9 downto 0) :="0000100011"; --35 (2+33) vertical back porch and sync
constant vfp: std_logic_vector(9 downto 0) :="1000000011"; --515 (525-10) vertical front

signal hcs,vcs: std_logic_vector(9 downto 0); --counters of position
signal vsen: std_logic:='0'; --enable the vertical counter

begin
    --counter for the horizontal sync signal
    process(clk,clr)
    begin
        if clr = '1' then
            hcs <= (others=>'0');
        elsif (clk'event and clk = '1') then
            if hcs = hpixels - 1 then --the counter has reached the end 
            hcs <= (others=>'0');
            vsen <= '1';
            else
            hcs <= hcs + 1;
            vsen <= '0';
            end if;
        end if;
    end process;
    hsync <= '0' when hcs < 96 else '1'; --horizontal sync pulse is low when hc is 0-95
    --counter for the vertical sync signal
    process(clk,clr, vsen)
    begin
        if clr = '1' then
        vcs <= (others=>'0');
        elsif rising_edge(clk) and vsen='1' then
                if vcs = vlines - 1 then --reset when number of lines is reached
                    vcs <= (others=>'0');
                else
                    vcs <= vcs + 1;
                end if;
            end if;
     end process;
     
     --process(clk, vcs, hcs)
     --begin
     --    if rising_edge(clk) then
             vsync <= '0' when vcs < 2 else '1'; --horizontal sync pulse is low when vcs is 0-1
             --enable video out when within the porches
             vidon <= '1' when (((hcs<hfp) and (hcs>=hbp)) and ((vcs<vfp) and (vcs>=vbp))) else '0';
             --output horizontal and vertical counters
             hc <= hcs;
             vc <= vcs;
             vsenable <= vsen;
     --    end if;
     --end process;
     
end main;