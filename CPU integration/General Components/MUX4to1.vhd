LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MUX_4to1 IS
    GENERIC (
        WIDTH : INTEGER := 16  -- Default input width is 8 bits
    );
    PORT (
        Sel : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);         -- 2-bit selector
        A, B, C, D : IN  STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0); -- 4 inputs
        Y : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0)     -- Output
    );
END ENTITY;

ARCHITECTURE Behavioral OF MUX_4to1 IS
BEGIN
    PROCESS (Sel, A, B, C, D)
    BEGIN
        CASE Sel IS
            WHEN "00" =>
                Y <= A;
            WHEN "01" =>
                Y <= B;
            WHEN "10" =>
                Y <= C;
            WHEN "11" =>
                Y <= D;
            WHEN OTHERS =>
                Y <= (OTHERS => '0'); -- Default case
        END CASE;
    END PROCESS;
END ARCHITECTURE;