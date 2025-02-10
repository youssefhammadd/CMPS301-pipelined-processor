LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY FlushUnit IS
    PORT (
        
        Exception_occurred_in_fetch   : IN std_logic;  
		Exception_occurred_in_Memory   : IN std_logic;  
		
        Flush_fetchDecode : OUT std_logic;  -- Flush signal for fetch-decode stage
        Flush_decodeExecute : OUT std_logic;  -- Flush signal for decode-execute stage
		Flush_executeMemory,
		Flush_memoryWriteBack : OUT std_logic
    );
END ENTITY;

ARCHITECTURE FlushUnit_Arch OF FlushUnit IS
BEGIN
	Flush_fetchDecode <= 
		'1' WHEN (Exception_occurred_in_fetch = '1' OR Exception_occurred_in_Memory= '1') ELSE
		'0';

	Flush_decodeExecute <= 
		'1' WHEN (Exception_occurred_in_Memory= '1') ELSE
		'0';
    Flush_executeMemory <= 
		'1' WHEN ( Exception_occurred_in_Memory= '1') ELSE
		'0';
    Flush_memoryWriteBack <= 
		'1' WHEN ( Exception_occurred_in_Memory= '1') ELSE
		'0';
	
END ARCHITECTURE;
