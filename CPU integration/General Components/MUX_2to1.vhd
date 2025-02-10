LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;


ENTITY MUX_2to1 IS
	GENERIC (
		WIDTH : integer := 12
	);
    PORT (
		Sel     : IN  STD_LOGIC;   -- Selector
        A, B    : IN std_logic_vector(WIDTH-1 DOWNTO 0);   -- Inputs
        Y       : OUT std_logic_vector(WIDTH-1 DOWNTO 0)    -- Output
    );
END ENTITY;

ARCHITECTURE Behavioral OF MUX_2to1 IS
BEGIN
    PROCESS (A, B, Sel)
    BEGIN
        IF Sel = '0' THEN
            Y <= A;
        ELSE
            Y <= B;
        END IF;
    END PROCESS;
END ARCHITECTURE;
