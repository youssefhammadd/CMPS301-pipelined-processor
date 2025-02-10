LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY PC IS
	
	PORT (pc_clk, pc_reset, pc_disable : IN  std_logic;
          pc_address_in : IN std_logic_vector(15 DOWNTO 0);
		  pc_address_out : OUT std_logic_vector(15 DOWNTO 0)
        );
END PC;

ARCHITECTURE PC_design OF PC IS
BEGIN

    PROCESS (pc_clk,pc_reset)
    
    BEGIN

        IF pc_reset = '1' THEN
            pc_address_out <= (others => '0');
        -- Was rising
        ELSIF rising_edge(pc_clk) THEN
            IF pc_disable = '0' THEN
               pc_address_out <= pc_address_in;
            END IF;
        END IF;
    END PROCESS;
		
END PC_design;