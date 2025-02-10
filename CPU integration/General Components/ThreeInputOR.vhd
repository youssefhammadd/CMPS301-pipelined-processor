library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity declaration
entity ThreeInputOR is
    Port (
        A : in STD_LOGIC;
        B : in STD_LOGIC;
        C : in STD_LOGIC;
        Y : out STD_LOGIC
    );
end ThreeInputOR;

-- Architecture body
architecture Behavioral of ThreeInputOR is
begin
    -- Concurrent assignment implementing the OR gate
    Y <= A or B or C;
end Behavioral;