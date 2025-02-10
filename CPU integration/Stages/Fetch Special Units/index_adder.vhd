LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY index_adder IS
	generic (
		WIDTH : integer := 16
	);
	PORT(
		index_bit : IN std_logic;
		index_adder_summation : OUT std_logic_vector(WIDTH-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE index_adder_design OF index_adder IS
BEGIN
	Adding :  entity work.n_BitsAdder 
	GENERIC MAP(WIDTH) 
	PORT MAP( 
	A   =>  "0000000000000011",
	B   =>  "0000000000000000",
	Cin =>  index_bit,
	Sum =>  index_adder_summation,
	Cout => open
	);
    
		
END ARCHITECTURE;