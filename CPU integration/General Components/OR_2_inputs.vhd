LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;


ENTITY OR_2_inputs IS
    PORT (
        A : IN  STD_LOGIC;  -- Input 1
        B : IN  STD_LOGIC;  -- Input 2
        Y : OUT STD_LOGIC   -- Output
    );
END ENTITY;

-- Architecture implementation
ARCHITECTURE Behavioral OF OR_2_inputs IS
BEGIN
    Y <= A or B;  -- OR operation between inputs A and B
END ARCHITECTURE;
