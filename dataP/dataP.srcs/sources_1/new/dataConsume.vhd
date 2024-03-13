----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.03.2024 11:41:26
-- Design Name: 
-- Module Name: dataConsume - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.common_pack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dataConsume is
  	port (
	  clk:		in std_logic;
		reset:		in std_logic; -- synchronous reset
		start: in std_logic; -- goes high to signal data transfer
		numWords_bcd: in BCD_ARRAY_TYPE(2 downto 0);
		ctrlIn: in std_logic; --ctrl_2
		ctrlOut: out std_logic; --ctrl_1
		data: in std_logic_vector(7 downto 0);
		dataReady: out std_logic;
		byte: out std_logic_vector(7 downto 0);
		seqDone: out std_logic;
		maxIndex: out BCD_ARRAY_TYPE(2 downto 0);
		dataResults: out CHAR_ARRAY_TYPE(0 to RESULT_BYTE_NUM-1) -- index 3 holds the peak
  	);
end dataConsume;

architecture Behavioral of dataConsume is
    Type State_type is (INIT, STORE, INDEX, REQ, GET, DONE);
    Signal currState, nextState : State_type;
begin
    stateLogic : process (reset, clk)
    BEGIN
        --
        IF (reset = '1') THEN
            currState <= INIT;
        ELSIF start = '1' AND rising_edge(clk) THEN
            currState <= nextState;
        END IF;
    END PROCESS;
    
    nextStateLogic : process (ctrlIn)
    BEGIN
        --
    END PROCESS;
    
    Output : process (currState)
    BEGIN
     --
    END PROCESS;

end Behavioral;
