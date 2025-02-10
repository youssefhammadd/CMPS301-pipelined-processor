LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY PredictionUnit IS
    PORT (
       
        branch_result   : IN std_logic;  -- Branch result input
        Flush_fetchDecode : OUT std_logic;  -- Flush signal for fetch-decode stage
        Flush_decodeExecute : OUT std_logic
    );
END ENTITY;

ARCHITECTURE PredictionUnit_Arch OF PredictionUnit IS
BEGIN


Flush_fetchDecode <= branch_result;
Flush_decodeExecute <= branch_result; 
          



END ARCHITECTURE;
