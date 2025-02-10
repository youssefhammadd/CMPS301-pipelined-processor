library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity write_back_cycle is
    Port (
		
        Alu_Res : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 1
        Mem_out : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 2
        IN_port : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 3
        MTR : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);         -- 2-bit selector
        Write_back : out STD_LOGIC_VECTOR(15 downto 0)        -- Output
    );
end write_back_cycle;

architecture write_back_cycle_arch of write_back_cycle is
begin
	PROCESS (MTR, Alu_Res, Mem_out,IN_port)
    BEGIN
        CASE MTR IS
            WHEN "00" =>
                Write_back <= Alu_Res;
            WHEN "01" =>
                Write_back <= Mem_out;
            WHEN "10" =>
                Write_back <= IN_port;
            WHEN OTHERS =>
                Write_back <= (OTHERS => '0'); -- Default case

        END CASE;
    END PROCESS;
end write_back_cycle_arch;

