LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY pc_adder IS
	generic (
		WIDTH : integer := 16
	);
	PORT(
		pc_adder_address_out, pc_adder_src2 : IN std_logic_vector(WIDTH-1 DOWNTO 0);
	    pc_adder_summation : OUT std_logic_vector(WIDTH-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE PC_adder_design OF pc_adder IS
BEGIN
	Adding :  entity work.n_BitsAdder 
	GENERIC MAP(WIDTH) 
	PORT MAP( 
	A   =>  pc_adder_address_out,
	B   =>  pc_adder_src2,
	Cin =>  '0',
	Sum =>  pc_adder_summation,
	Cout => open
	);
    
		
END ARCHITECTURE;