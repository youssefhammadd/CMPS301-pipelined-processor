LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;


ENTITY WriteBack_Value is

PORT( 
	Flag_Restored : IN STD_LOGIC;
	Write_Back_Value : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	PC_Value : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END ENTITY;



ARCHITECTURE WriteBack_Value_Arch of WriteBack_Value IS 

BEGIN 
	PC_Value <= 
			"000" & Write_Back_Value(12 DOWNTO 0) WHEN Flag_Restored ='1' ELSE
			Write_Back_Value;
				

END ARCHITECTURE;