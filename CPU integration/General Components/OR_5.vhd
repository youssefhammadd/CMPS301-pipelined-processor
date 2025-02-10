library ieee;
use ieee.std_logic_1164.all;

entity OR_5 is
    port (
        A, B, C, D, E : in std_logic; -- 5 inputs
        Y : out std_logic            -- Output
    );
end entity OR_5;

architecture Behavioral of OR_5 is
begin
    -- OR operation on 5 inputs
    Y <= A or B or C or D or E;
end architecture Behavioral;
