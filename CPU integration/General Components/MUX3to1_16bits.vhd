library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX3to1_16bits is
    Port (
        A : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 1
        B : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 2
        C : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 3
        SEL : in STD_LOGIC_VECTOR(1 downto 0); -- 2-bit Select signal
        Y : out STD_LOGIC_VECTOR(15 downto 0)        -- Output
    );
end MUX3to1_16bits;

architecture MUX3to1_16bits_arch of MUX3to1_16bits is
begin
    process(A, B, C, SEL)
    begin
        case SEL is
            when "00" => 
                Y <= A;          -- Select Input A
            when "01" => 
                Y <= B;          -- Select Input B
            when "10" => 
                Y <= C;          -- Select Input C
            when others => 
                Y <= (others => '0');        -- Default case (e.g., invalid SEL value)
        end case;
    end process;
end MUX3to1_16bits_arch;
