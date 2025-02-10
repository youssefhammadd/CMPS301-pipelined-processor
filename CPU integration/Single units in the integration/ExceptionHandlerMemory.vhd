LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY ExceptionHandlerMemory is

	GENERIC (
		PC_Width : integer := 16;
		SP_Width : integer := 16
	);

	PORT (
		  clk : IN STD_LOGIC;
		  Can_Cause_Exception : IN  std_logic;
		  
		  SP_plus_SP_minus : IN STD_LOGIC_VECTOR(1 DOWNTO 0 );
		  
		  SP_new_in: IN STD_LOGIC_VECTOR( SP_Width-1 DOWNTO 0 );
		  SP_old_in: IN STD_LOGIC_VECTOR( SP_Width-1 DOWNTO 0 );
		  
		  PC_in : IN STD_LOGIC_VECTOR( PC_Width-1 DOWNTO 0 );
		  PC_out : OUT STD_LOGIC_VECTOR( PC_Width-1 DOWNTO 0 );
		  
		  Exception_Chosen_Address,
		  Exception_occurred: OUT  std_logic	  
	);
END ENTITY;

ARCHITECTURE ExceptionHandlerMemory_Arch OF ExceptionHandlerMemory IS



	
BEGIN


	
	PROCESS(clk , Can_Cause_Exception)
	BEGIN 
	IF Can_Cause_Exception = '0' THEN 
		Exception_Chosen_Address <= '0';
		Exception_occurred <= '0' ;
		
	
	ELSIF Can_Cause_Exception = '1' AND FALLING_EDGE(clk)  THEN
		IF ((SP_new_in(12) = '1') AND ( SP_new_in(14) ='0' AND SP_new_in(15) ='0' AND SP_new_in(13) = '0') AND SP_old_in = "0000111111111111") AND SP_plus_SP_minus = "10" THEN
			Exception_Chosen_Address <= '0';
			Exception_occurred <= '1' ;
		ELSIF (SP_new_in(12) = '1' OR SP_new_in(14) ='1' OR SP_new_in(15) ='1' OR SP_new_in(13) = '1') THEN
			Exception_Chosen_Address <= '1';
			Exception_occurred <= '1' ;
		ELSE 
			Exception_Chosen_Address <= '0';
			Exception_occurred <= '0' ;
		END IF;
	END IF;
	END PROCESS;
	
	PC_out <= PC_in;
	

    
END ARCHITECTURE;


	---Exception_Chosen_Address <= 
	---	--when it is not an overflow(jump)
	---	'1' WHEN (Can_Cause_Exception = '1' AND (SP_new_in /= SP_old_plus_1_value) AND 
	---	( SP_new_in(12) = '1' OR  SP_new_in(13) = '1' OR SP_new_in(14) = '1' OR SP_new_in(15) = '1' ) ) ELSE
	---	'0';
	---Exception_occurred <= 
	---	'1' WHEN (( SP_new_in(12) = '1' OR  SP_new_in(13) = '1' OR SP_new_in(14) = '1' OR SP_new_in(15) = '1' )  AND Can_Cause_Exception = '1') ELSE
	---	'0';
	---	
	---PC_out <= PC_in;

