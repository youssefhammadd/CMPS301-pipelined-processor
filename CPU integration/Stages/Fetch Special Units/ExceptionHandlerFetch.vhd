LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY ExceptionHandlerFetch is

	GENERIC (

		WIDTH_16 : integer := 16
	);

	PORT (
		  PC_disabled_or_not  : IN STD_LOGIC;
		  PC_in_to_IM : IN STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
		  PC_old_in: IN STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
		  


		  PC_to_EPC: OUT STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
		  Exception_Chosen_Address,
		  Exception_occurred: OUT  std_logic	  
	);
END ENTITY;

ARCHITECTURE ExceptionHandlerFetch_Arch OF ExceptionHandlerFetch IS

SIGNAL PC_old_plus_1_value : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
SIGNAL PC_old_plus_2_value : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	
BEGIN
	Adding1 : entity work.n_BitsAdder 
	GENERIC MAP(WIDTH_16) 
	PORT MAP( 
	A   =>  PC_old_in,
	B   =>  (OTHERS => '0'),
	Cin =>  '1',
	Sum =>  PC_old_plus_1_value,
	Cout => open
	);
	
	Adding2 : entity work.n_BitsAdder 
	GENERIC MAP(WIDTH_16) 
	PORT MAP( 
	A   =>  PC_old_in,
	B   =>  ("0000000000000010"),
	Cin =>  '0',
	Sum =>  PC_old_plus_2_value,
	Cout => open
	);
	
	Exception_Chosen_Address <= 
		--when it is not an overflow(jump)
		'1' WHEN (PC_disabled_or_not = '0' AND (PC_in_to_IM /= PC_old_plus_1_value AND PC_in_to_IM /= PC_old_plus_2_value ) AND 
		( PC_in_to_IM(12) = '1' OR  PC_in_to_IM(13) = '1' OR PC_in_to_IM(14) = '1' OR PC_in_to_IM(15) = '1' ) ) ELSE
		'0';
	Exception_occurred <= 
	'1' WHEN (( PC_in_to_IM(12) = '1' OR  PC_in_to_IM(13) = '1' OR PC_in_to_IM(14) = '1' OR PC_in_to_IM(15) = '1' )  AND PC_disabled_or_not = '0') ELSE
	'0';
		
	PC_to_EPC <= PC_in_to_IM;

	
	
	
	
    
END ARCHITECTURE;



