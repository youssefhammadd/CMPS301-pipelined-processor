library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Branching is
    port(
        flags_in  					  : in STD_LOGIC_VECTOR(2 downto 0);
 
        control_Z        			  : in STD_LOGIC;
        control_N        			  : in STD_LOGIC;
        control_C                  : in STD_LOGIC;
        
        unconditional_branching    : in STD_LOGIC;
		  
        Branching_bool             : out STD_LOGIC;
        flags_out                  : out STD_LOGIC_VECTOR(2 downto 0)
    );
end Branching;

architecture Behavioral of Branching is

		SIGNAL C_out , Z_out, N_out , oring_out : STD_LOGIC;
		
begin

    C_out <= flags_in(2) AND control_C;
	 Z_out <= flags_in(0) AND control_Z;
	 N_out <= flags_in(1) AND control_N;
	 
	 oring_out <= C_out or Z_out or N_out;
	 
	 Branching_bool <= '1' WHEN unconditional_branching = '1'
							ELSE oring_out;
	
     flags_out(2) <= C_out;
	  flags_out(1) <= N_out;
	  flags_out(0) <= Z_out;

end Behavioral;
