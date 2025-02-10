LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY RET_unit IS
    PORT (
        
        branch_result   : IN std_logic;  -- Branch result input
		Mux_address_selector : OUT std_logic;
        Flush_fetchDecode : OUT std_logic;  -- Flush signal for fetch-decode stage
        Flush_decodeExecute : OUT std_logic;  -- Flush signal for decode-execute stage
		Flush_executeMemory : OUT std_logic
    );
END ENTITY;

ARCHITECTURE RET_unit_Arch OF RET_unit IS
BEGIN
	Mux_address_selector <= branch_result;
	
	Flush_fetchDecode <= branch_result;
	Flush_decodeExecute <= branch_result;
    Flush_executeMemory <= branch_result;
    
END ARCHITECTURE;
