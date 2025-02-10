LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

ENTITY pc_one_adder IS
	generic (
		WIDTH : integer := 16
	);
	PORT(
		pc_in : IN std_logic_vector(WIDTH-1 DOWNTO 0);
		pc_increment : OUT std_logic_vector(WIDTH-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE pc_one_adder_arch OF pc_one_adder IS
BEGIN
	Adding :  entity work.n_BitsAdder 
	GENERIC MAP(WIDTH) 
	PORT MAP( 
	A   =>  "0000000000000001",
	B   =>  pc_in,
	Cin =>  '0',
	Sum =>  pc_increment,
	Cout => open
	);
    
END ARCHITECTURE;