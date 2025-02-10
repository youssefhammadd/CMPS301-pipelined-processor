LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY EPC_Unit IS
	
	PORT(
		rst,
		Write_Enable_From_DM,
		Write_Enable_From_IM : IN std_logic;
		PC_From_Fetch ,
		PC_From_Memory : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		PC_caused_exception : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE EPC_Unit_design OF EPC_Unit IS
BEGIN


	
	PROCESS (rst , Write_Enable_From_DM , Write_Enable_From_IM ,PC_From_Memory , PC_From_Fetch)
    BEGIN
	
	IF rst = '1' THEN 
	
        PC_caused_exception <= (OTHERS=>'0'); 
			
    ELSIF Write_Enable_From_DM = '1' THEN
	
        PC_caused_exception <= PC_From_Memory;
	ELSIF Write_Enable_From_IM = '1' THEN
		PC_caused_exception <= PC_From_Fetch;
	ELSE
    END IF;
    END PROCESS;
    
		
END ARCHITECTURE;