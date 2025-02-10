--include the used library
LIBRARY ieee;
USE ieee.std_logic_1164.all;

--entity for 1 bit D - flip flop
ENTITY DFF_entity IS 

	PORT( 
		clk  : IN STD_LOGIC;
		D    : IN STD_LOGIC;
		Q    : OUT STD_LOGIC
		
		--enable : IN STD_LOGIC
	);
	
END DFF_entity;


--architecture of 1 bit D - flip flop without enbale
ARCHITECTURE DFF_Arch OF DFF_entity IS 

	SIGNAL Wire : STD_LOGIC;
BEGIN
	Wire <= D;
	PROCESS(clk)

	BEGIN 
		IF RISING_EDGE(clk) THEN 
			Q <= Wire ;
		END IF;
		--the synthesizer understands that else Q is equal to Q (no change)
	
	END PROCESS;

END DFF_arch;



--architecture of 1 bit D - flip flop with Synchronous enable
--ARCHITECTURE DFF_Arch OF DFF IS 
--
--BEGIN
--	PROCESS(clk )
--
--	BEGIN 
--		IF RISING_EDGE(clk) THEN 
--		
--			IF enable = '1' THEN
--				Q <= D ;
--				Qbar <= (not D);
--			END IF;
--			
--		END IF;
--		--the synthesizer understands that else Q is equal to Q (no change)
--	
--	END PROCESS;
--
--END DFF_arch;


--architecture of 1 bit D - flip flop with Asyncronous enable
--ARCHITECTURE DFF_Arch OF DFF IS 
--
--BEGIN
--	PROCESS(clk , enable)
--
--	BEGIN 
--	
--		IF enable = '1' THEN
--		
--			IF RISING_EDGE(clk) THEN 
--				Q <= D ;
--			END IF;
--			
--		END IF;
--		--the synthesizer understands that else Q is equal to Q (no change)
--	
--	END PROCESS;
--
--END DFF_arch;