LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY n_BitsAdder IS
	--generic
	generic (
		WIDTH : integer := 12
	);

	PORT( 
		A,B : IN std_logic_vector( WIDTH-1 DOWNTO 0);
		Cin : IN std_logic;
        Sum : OUT std_logic_vector( WIDTH-1 DOWNTO 0);
		Cout : OUT std_logic
	); 
END n_BitsAdder;






ARCHITECTURE n_BitsAdder_Arch OF n_BitsAdder IS

	SIGNAL c : std_logic_vector(WIDTH DOWNTO 0);
BEGIN

c(0) <= Cin;

loop1: FOR i IN 0 TO WIDTH-1 GENERATE
        fx: entity work.oneBitAdder PORT MAP(A(i),B(i),c(i),Sum(i),c(i+1));
END GENERATE;
	

Cout <= c(WIDTH);

END n_BitsAdder_Arch;