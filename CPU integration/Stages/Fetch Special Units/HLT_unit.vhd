LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY HLT_unit IS
	
	PORT(
		HLT_unit_pc_disable_in,
		HLT_unit_reset : IN std_logic;
	    HLT_unit_pc_disable_out : OUT std_logic
    );
END ENTITY;

ARCHITECTURE HLT_unit_design OF HLT_unit IS
BEGIN


	
	PROCESS (HLT_unit_pc_disable_in, HLT_unit_reset)
    BEGIN
	
		IF HLT_unit_reset = '1' THEN 
		
            HLT_unit_pc_disable_out <= '0'; --enable the PC
				
        ELSIF HLT_unit_pc_disable_in = '1' THEN
		
            HLT_unit_pc_disable_out <= '1';--disable the PC
		ELSE
				
			
      END IF;
    END PROCESS;
    
		
END ARCHITECTURE;