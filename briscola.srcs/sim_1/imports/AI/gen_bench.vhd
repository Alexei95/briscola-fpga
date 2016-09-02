--------------------------------------------------------------------------------
-- Company: 
-- Engineer: Paolo Notaro
--
-- Create Date:   13:13:42 05/24/2016
-- Design Name:   
-- Module Name:   C:/Users/Paolo/Documents/Xilinx ISE Suite/AI/gen_bench.vhd
-- Project Name:  AI
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: AI_block
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.data.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY gen_bench IS
END gen_bench;
 
ARCHITECTURE behavior OF gen_bench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT AI_block
    PORT(
         DRAWN_CARD : IN  card;
         OPPONENT_CARD : IN  card;
         BRISCOLA_INFOS : IN  card;
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         TURN : IN  std_logic;
         CARD_OUT : OUT  card
        );
    END COMPONENT;
    

   --Inputs
   signal DRAWN_CARD : card:=(suit=>CUPS,value=>EMPTY,points=>0); --all drawn cards arrive impulsively
   signal OPPONENT_CARD : card:=(suit=>CUPS,value=>EMPTY,points=>0);
   signal BRISCOLA_INFOS : card:=(suit=>CUPS,value=>EMPTY,points=>0);
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';
   signal TURN : std_logic := '0';

 	--Outputs
   signal CARD_OUT : card:=(suit=>CUPS,value=>EMPTY,points=>0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: AI_block PORT MAP (
          DRAWN_CARD => DRAWN_CARD,
          OPPONENT_CARD => OPPONENT_CARD,
          BRISCOLA_INFOS => BRISCOLA_INFOS,
          CLK => CLK,
          RESET => RESET,
          TURN => TURN,
          CARD_OUT => CARD_OUT
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 50 ns.
      RESET <='1';	
		wait for CLK_period*5;
		RESET <='0';
		--initial hand
		DRAWN_CARD<=(suit=>SWORDS,value=>SEVEN,points=>0);
		wait for CLK_period * 5;
		DRAWN_CARD<=(suit=>CLUBS,value=>KING,points=>4);
		wait for CLK_period * 5;
		DRAWN_CARD<=(suit=>CLUBS,value=>SEVEN,points=>0);
		wait for CLK_period * 5;
		--back to normal
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		--briscola comes
		BRISCOLA_INFOS<=(suit=>COINS,value=>JACK,points=>2);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays second:
		OPPONENT_CARD<=(suit=>CUPS,value=>SEVEN,points=>0); --user card
		TURN<='0';
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>SWORDS,value=>HORSE,points=>3);
		wait for CLK_PERIOD * 5;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays second:
		wait for 2*CLK_PERIOD; --user plays a card (very fast indeed)
		OPPONENT_CARD<=(suit=>CUPS,value=>TWO,points=>0);
		TURN<='0';
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>SWORDS,value=>KING,points=>4);
		wait for CLK_PERIOD * 5;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays second:
		wait for 2*CLK_PERIOD; --user plays a card (very fast indeed)
		OPPONENT_CARD<=(suit=>SWORDS,value=>TWO,points=>0);
		TURN<='0';
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>COINS,value=>FIVE,points=>0);
		wait for CLK_PERIOD * 5;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays first:
		TURN<='1';
		OPPONENT_CARD<=(suit=>CUPS,value=>SIX,points=>0);
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>CUPS,value=>ACE,points=>11);
		wait for CLK_PERIOD * 5;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays first:
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
		wait for 2*CLK_PERIOD; --user response to card (very fast indeed)
		OPPONENT_CARD<=(suit=>SWORDS,value=>JACK,points=>2);
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>CLUBS,value=>FOUR,points=>3);
		wait for CLK_PERIOD;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays first:
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
		wait for 2*CLK_PERIOD; --user response to card (very fast indeed)
		OPPONENT_CARD<=(suit=>CLUBS,value=>ACE,points=>11);
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>SWORDS,value=>ACE,points=>11);
		wait for CLK_PERIOD;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays second:
		wait for 2*CLK_PERIOD; --user plays a card (very fast indeed)
		OPPONENT_CARD<=(suit=>SWORDS,value=>FOUR,points=>0);
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
		
		--SUDDEN USER RESET
		--wait for 10*CLK_PERIOD;
		--RESET<='1';
		--WAIT FOR CLK_PERIOD;
		--RESET<='0';
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>CUPS,value=>FOUR,points=>0);
		wait for CLK_PERIOD;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays second:
		wait for 2*CLK_PERIOD; --user plays a card (very fast indeed)
		OPPONENT_CARD<=(suit=>CLUBS,value=>FIVE,points=>0);
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';

		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>SWORDS,value=>FIVE,points=>0);
		wait for CLK_PERIOD;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays first:
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
		wait for 2*CLK_PERIOD; --user response to card (very fast indeed)
		OPPONENT_CARD<=(suit=>SWORDS,value=>THREE,points=>10);
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>CUPS,value=>KING,points=>4);
		wait for CLK_PERIOD;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays second:
		wait for 2*CLK_PERIOD; --user plays a card (very fast indeed)
		OPPONENT_CARD<=(suit=>CUPS,value=>HORSE,points=>3);
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>CLUBS,value=>JACK,points=>2);
		wait for CLK_PERIOD;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays first:
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
		wait for 2*CLK_PERIOD; --user response to card (very fast indeed)
		OPPONENT_CARD<=(suit=>COINS,value=>TWO,points=>0);
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>COINS,value=>THREE,points=>10);
		wait for CLK_PERIOD;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays second:
		wait for 2*CLK_PERIOD; --user plays a card (very fast indeed)
		OPPONENT_CARD<=(suit=>COINS,value=>FOUR,points=>0);
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>COINS,value=>ACE,points=>11);
		wait for CLK_PERIOD;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays first:
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
		wait for 2*CLK_PERIOD; --user response to card (very fast indeed)
		OPPONENT_CARD<=(suit=>COINS,value=>SIX,points=>0);
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>CLUBS,value=>SIX,points=>0);
		wait for CLK_PERIOD;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays second:
		wait for 2*CLK_PERIOD; --user plays a card (very fast indeed)
		OPPONENT_CARD<=(suit=>CLUBS,value=>TWO,points=>0);
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
      wait;
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>SWORDS,value=>SIX,points=>0);
		wait for CLK_PERIOD;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>CUPS,value=>JACK,points=>2);
		
		--AI plays first:
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
		wait for 2*CLK_PERIOD; --user response to card (very fast indeed)
		OPPONENT_CARD<=(suit=>CUPS,value=>THREE,points=>10);
		
		--drawing
		wait for 2*CLK_PERIOD; --server computing score, giving new cards
		DRAWN_CARD<=(suit=>COINS,value=>KING,points=>4);
		wait for CLK_PERIOD;
		DRAWN_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		OPPONENT_CARD<=(suit=>COINS,value=>EMPTY,points=>0);
		
		--AI plays second:
		wait for 2*CLK_PERIOD; --user plays a card (very fast indeed)
		OPPONENT_CARD<=(suit=>CUPS,value=>FIVE,points=>0);
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
      wait;
		
		--END OF DRAWING
		
		--AI plays first:
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
		wait for 2*CLK_PERIOD; --user response to card (very fast indeed)
		OPPONENT_CARD<=(suit=>CLUBS,value=>HORSE,points=>3);
		
		--AI plays first:
		TURN<='1';
		wait for CLK_PERIOD; --wait AI response
		TURN<='0';
		wait for 2*CLK_PERIOD; --user response to card (very fast indeed)
		OPPONENT_CARD<=(suit=>CUPS,value=>SEVEN,points=>0);
		
		--END OF GAME
   end process;

END;
