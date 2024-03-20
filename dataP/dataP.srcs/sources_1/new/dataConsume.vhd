--------------------------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
use IEEE.NUMERIC_STD.ALL;
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
    signal maxCount : integer;
    signal c: integer;
    SIGNAL results : CHAR_ARRAY_TYPE(0 to RESULT_BYTE_NUM-1);
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
    
    nextStateLogic : process (ctrlIn, currState)
    BEGIN
        --
        --maxCount <= (to_integer(unsigned(numWords_bcd(2))) * 100) + (to_integer(unsigned(numWords_bcd(1))) * 10) + to_integer(unsigned(numWords_bcd(0)));
        CASE currState IS 
            WHEN INIT =>
                IF ctrlIn'EVENT THEN
                    nextState <= STORE;
                ELSE 
                    nextState <= INIT;
                END IF;
            
            WHEN STORE =>
                maxCount <= (to_integer(unsigned(numWords_bcd(2))) * 100) + (to_integer(unsigned(numWords_bcd(1))) * 10) + to_integer(unsigned(numWords_bcd(0)));
                IF maxCount > c THEN
                    nextState <= INDEX;
                ELSE
                    nextState <= DONE;
                END IF;
                
            WHEN INDEX =>
                IF ((c < 5) OR (NOT((results(2)<results(3)) AND (results(4)<results(3))))) AND ctrlIn'EVENT THEN
                    nextState <= STORE;
                ELSIF NOT((c < 5) OR (NOT((results(2)<results(3)) AND (results(4)<results(3))))) AND ctrlIn'EVENT THEN
                    nextState <= GET;
                ELSE 
                    nextState <= INDEX;
                END IF;
            
            WHEN GET =>
                maxCount <= (to_integer(unsigned(numWords_bcd(2))) * 100) + (to_integer(unsigned(numWords_bcd(1))) * 10) + to_integer(unsigned(numWords_bcd(0)));
                IF maxCount > c THEN
                    nextState <= REQ;
                ELSE
                    nextState <= DONE;
                END IF;
            
            WHEN REQ =>
                IF ctrlIn'EVENT THEN
                    nextState <= GET;
                ELSE 
                    nextState <= REQ;
                END IF;
            WHEN DONE =>
                nextState <= INIT;
        END CASE;
    END PROCESS;
    
    Output : process (currState)
    BEGIN
     --
    END PROCESS;

end Behavioral;
