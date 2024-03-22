----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.03.2024 11:34:15
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
		ctrlIn: in std_logic;
		ctrlOut: out std_logic;
		data: in std_logic_vector(7 downto 0);
		dataReady: out std_logic;
		byte: out std_logic_vector(7 downto 0);
		seqDone: out std_logic;
		maxIndex: out BCD_ARRAY_TYPE(2 downto 0);
		dataResults: out CHAR_ARRAY_TYPE(0 to RESULT_BYTE_NUM-1) -- index 3 holds the peak 
		);
end dataConsume;

architecture Behavioral of dataConsume is
    TYPE STATE_TYPE is (INIT, STORE, INDEX, SAVE, DONE);
    SIGNAL curState, nextState : STATE_TYPE;      
     
    SIGNAL c : integer;
    SIGNAL intMaxIndex2 : integer;
    SIGNAL intMaxIndex : integer;
    
    SIGNAL dataResults2 : CHAR_ARRAY_TYPE(0 to RESULT_BYTE_NUM-1);
    SIGNAL peakResult : signed(7 downto 0) := (others => '0');
    SIGNAL test : integer;
begin
    
    stateLogic : process (reset, clk)
    BEGIN
        IF (reset = '1') THEN
            curState <= INIT;
        ELSIF start = '1' AND rising_edge(clk) THEN
            curState <= nextState;
        END IF;
    END PROCESS;
    
    nextStateLogic : process (ctrlIn, curState)
    variable maxCount : integer;
    BEGIN
        --
        --maxCount <= (to_integer(unsigned(numWords_bcd(2))) * 100) + (to_integer(unsigned(numWords_bcd(1))) * 10) + to_integer(unsigned(numWords_bcd(0)));
        CASE curState IS 
            WHEN INIT =>
                IF ctrlIn'EVENT THEN
                    nextState <= STORE;
                ELSE 
                    nextState <= INIT;
                END IF;
            
            WHEN STORE =>
                maxCount := (to_integer(unsigned(numWords_bcd(2))) * 100) + (to_integer(unsigned(numWords_bcd(1))) * 10) + to_integer(unsigned(numWords_bcd(0)));
                IF (maxCount > c +1) THEN
                    nextState <= INDEX;
                ELSE
                    nextState <= DONE;
                END IF;
                test <= 0;
                
            WHEN INDEX =>
                IF ctrlIn'EVENT THEN
                    IF NOT(signed(dataResults2(3)) > peakResult) THEN
                        nextState <= STORE;
                        test <= 1;
                    ELSIF ((c < 5) OR NOT ((signed(dataResults2(2)) < signed(dataResults2(3))) AND (signed(dataResults2(3)) > signed(dataResults2(4))))) THEN
                       nextState <= STORE;
                       test <= 2;
                    ELSE
                        nextState <= SAVE;
                   END IF;
                ELSE 
                    nextState <= INDEX;
                END IF;
            
            WHEN SAVE =>
                nextState <= STORE;
            WHEN DONE =>
                nextState <= INIT;
        END CASE;
    END PROCESS;
    
    output : process (curState)
    variable ctrl1 : std_logic := '0';    
    BEGIN
        IF (curState = INIT) THEN
            ctrl1 := NOT ctrl1;
            ctrlOut <= ctrl1;
            dataReady <= '0';
            seqDone <= '0';
            c <= 0;
            intMaxIndex2 <= 0;
        ELSIF (curState = STORE) THEN
            byte <= data;
            dataReady <= '1';
            dataResults2 <= dataResults2(1 to RESULT_BYTE_NUM-1) & data;
            c <= c +1;    
        ELSIF (curState = INDEX) THEN
            dataReady <= '0';
            ctrl1 := NOT ctrl1;
            ctrlOut <= ctrl1;
            intMaxIndex2 <= c -4;
        ELSIF (curState = SAVE) THEN
            dataResults <= dataResults2;
            peakResult <= signed(dataResults2(3));
            intMaxIndex <= intMaxIndex2;
        ELSIF (curState = DONE) THEN
            seqDone <= '1';
            peakResult <= (others => '0');
        --
        END IF;
    END PROCESS;
    
    BCDIndex : process (intMaxIndex)
    variable temp : integer;
    BEGIN
        temp := intMaxIndex;
        maxIndex(0) <= std_logic_vector(to_unsigned(temp mod 10, 4));
        temp := temp /10;
        maxIndex(1) <= std_logic_vector(to_unsigned(temp mod 10, 4));
        temp := temp /10;
        maxIndex(2) <= std_logic_vector(to_unsigned(temp mod 10, 4));
    END PROCESS;


end Behavioral;
