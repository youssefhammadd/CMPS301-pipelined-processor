LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL; 
 
  
ENTITY ALU IS 
		PORT  (	  
			 data_1  : IN STD_LOGIC_VECTOR(15 downto 0); 
			 data_2  : IN STD_LOGIC_VECTOR(15 downto 0);
			 ALU_sel : IN STD_LOGIC_VECTOR(2 downto 0);
			 ALU_res : OUT STD_LOGIC_VECTOR(15 downto 0);
			 CCR     : OUT STD_LOGIC_VECTOR(2 downto 0):= (others => '0') --condition code register (Zero, negative , carry)
               );
END ENTITY;

ARCHITECTURE A_ALU OF ALU IS
	
	SIGNAL prev_CCR : STD_LOGIC_VECTOR(2 downto 0):= (others => '0');  
	SIGNAL ALU_IN_RES: STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
	SIGNAL RES_C :STD_LOGIC_VECTOR(16 downto 0):= (others => '0');
		  
BEGIN

	 ALU_IN_RES <= NOT data_1 
					WHEN ALU_sel = "000"  --NOT
		
					ELSE data_1 AND data_2 
					WHEN ALU_sel = "001"  --AND
					
					ELSE std_logic_vector(to_signed(to_integer(signed(data_1)) - to_integer(signed(data_2)), 16))
					WHEN ALU_sel = "010" --SUB
					
					ELSE data_1           
					WHEN ALU_sel = "011"  --SETC
					
					ELSE data_1           
					WHEN ALU_sel = "100" --NOP1
					
					ELSE data_2           
					WHEN ALU_sel = "101" --NOP2
					
					ELSE std_logic_vector(to_signed(to_integer(signed(data_1)) + to_integer(signed(data_2)), 16)) 
					WHEN ALU_sel= "110" --ADD
					
					ELSE std_logic_vector(to_signed(to_integer(signed(data_1)) + 1, 16))  
					WHEN ALU_sel = "111" --INC
					
					ELSE (others => '0');
		
		RES_C <= std_logic_vector(to_unsigned(to_integer(unsigned(data_1)) + to_integer(unsigned(data_2)), 17))
					WHEN ALU_sel = "110" 
					ELSE std_logic_vector(to_unsigned(to_integer(unsigned(data_1)) + 1, 17))
					WHEN ALU_sel = "111";
					 
					
		ALU_res <= ALU_IN_RES;
					
		prev_CCR(0)  <= prev_CCR(0) WHEN (ALU_sel = "100" OR ALU_sel = "101" OR ALU_sel = "011")  -- No change in NOP or SETC
					ELSE '1' WHEN (ALU_IN_RES = "0000000000000000")  -- Set to 1 if result is zero
					ELSE '0';  -- Set to 0 if result is non-zero


		prev_CCR(1) <= prev_CCR(1) WHEN ALU_sel = "100" OR ALU_sel = "101" OR ALU_sel = "011" --no change in NOP OR SETC
					ELSE '1' WHEN ALU_IN_RES(15) = '1'  
					ELSE '0';
	
		prev_CCR(2) <= prev_CCR(2)  WHEN ALU_sel = "100" OR ALU_sel = "101" OR ALU_sel = "000" OR ALU_sel = "001" --no change in NOP & AND & NOT
					ELSE '1' WHEN ALU_sel = "011"   --SETC
								OR (ALU_sel = "010" AND to_integer(unsigned(data_1)) < to_integer(unsigned(data_2)))
					ElSE RES_C(16) WHEN ALU_sel = "110" or ALU_sel = "111"
					ELSE '0';
		
		CCR <= prev_CCR;


END A_ALU;