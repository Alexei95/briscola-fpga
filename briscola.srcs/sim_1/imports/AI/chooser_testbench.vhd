--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:45:01 05/21/2016
-- Design Name:   
-- Module Name:   C:/Users/Paolo/Documents/Xilinx ISE Suite/AI/chooser_testbench.vhd
-- Project Name:  AI
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: chooser
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 use work.data.ALL;
 
ENTITY chooser_testbench IS
END chooser_testbench;
 
ARCHITECTURE behavior OF chooser_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT chooser
    PORT(
         CLK : IN  std_logic;
         HAND_IN : IN  hand;
         TURN : IN  std_logic;
         BRISCOLA : IN  card;
         OPPONENT_CARD : IN  card;
         CHOSEN_CARD : OUT card
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal HAND_IN : hand:=(
				(suit=>COINS,value=>JACK,points=>2),
				(suit=>CLUBS,value=>HORSE,points=>3),
				(suit=>CLUBS,value=>EMPTY,points=>0)
			);
   signal TURN : std_logic := '0';
   signal BRISCOLA : card := (suit=>CUPS,value=>THREE,points=>10);
   signal OPPONENT_CARD : card :=(suit=>CUPS,value=>HORSE,points=>3);

 	--Outputs
   signal CHOSEN_CARD : card;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: chooser PORT MAP (
          CLK => CLK,
          HAND_IN => HAND_IN,
          TURN => TURN,
          BRISCOLA => BRISCOLA,
          OPPONENT_CARD => OPPONENT_CARD,
          CHOSEN_CARD => CHOSEN_CARD
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
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		TURN <= '1';
		wait;
		
   end process;

END;
