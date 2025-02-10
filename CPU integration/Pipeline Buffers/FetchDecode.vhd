--include the used library
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY FetchDecode IS
	GENERIC(
		InstructionWidth : INTEGER := 16; 
		-- the size of the instruction used
		ImmediateWidth : INTEGER := 16;
		InWidth :INTEGER := 16;
		PcWidth : INTEGER := 16;
		OpCodeWidth :INTEGER := 5;	
		AddressWidth : INTEGER := 3
 
	);
	
	
	PORT(
		clk : IN STD_LOGIC;
		Write_Disable : IN STD_LOGIC;
		Flush : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		Instruction : IN STD_LOGIC_VECTOR( InstructionWidth - 1 DOWNTO 0);
		ImmediateValue_in : IN STD_LOGIC_VECTOR( ImmediateWidth - 1 DOWNTO 0);
		InValue_in : IN STD_LOGIC_VECTOR( InWidth - 1 DOWNTO 0);
		PC_in : IN STD_LOGIC_VECTOR( PcWidth - 1 DOWNTO 0);
		OpCode : OUT STD_LOGIC_VECTOR (OpCodeWidth- 1 DOWNTO 0);
		Rsrc1_Address : OUT STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		Rsrc2_Address : OUT STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		Rdst_Address  : OUT STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		Index_bit : OUT STD_LOGIC;
		Imm_bit : OUT STD_LOGIC;
		ImmediateValue_out : OUT STD_LOGIC_VECTOR( ImmediateWidth - 1 DOWNTO 0);
		PC_out : OUT STD_LOGIC_VECTOR( PcWidth - 1 DOWNTO 0);
		InValue_out : OUT STD_LOGIC_VECTOR( InWidth - 1 DOWNTO 0)
	);
	
	
END ENTITY;




ARCHITECTURE FetchDecode_Arch OF FetchDecode IS

	
BEGIN
	PROCESS (clk , reset)
    BEGIN
		
		IF reset = '1' THEN
		  -- Reset the outputs when reset is active
		  OpCode <= (OTHERS => '0');
		  Rsrc1_Address <= (OTHERS => '0');
		  Rsrc2_Address <= (OTHERS => '0');
		  Rdst_Address <= (OTHERS => '0');
		  Index_bit <= '0';
		  Imm_bit <= '0';
		  ImmediateValue_out <= (OTHERS => '0');
		  InValue_out <= (OTHERS => '0');
		  PC_out <= (OTHERS => '0');
		ELSIF RISING_EDGE(clk) THEN
			IF Write_Disable = '0' AND Flush = '0' THEN
				-- Only update outputs when enable is '1'
				OpCode <= Instruction(15 DOWNTO 11);
				Rsrc1_Address <= Instruction(10 DOWNTO 8);
				Rsrc2_Address <= Instruction(7 DOWNTO 5);
				Rdst_Address <= Instruction(4 DOWNTO 2);
				Index_bit <= Instruction(1);
				Imm_bit <= Instruction(0);
				ImmediateValue_out <= ImmediateValue_in;
				InValue_out <= InValue_in;
				PC_out <= PC_in;
			ELSIF Write_Disable = '1' AND Flush = '0' THEN 
				--keep the values inside the register as it is no change
				
			ELSIF Flush = '1' THEN 
			
				OpCode <= (OTHERS => '0');
				Rsrc1_Address <= (OTHERS => '0');
				Rsrc2_Address <= (OTHERS => '0');
				Rdst_Address <= (OTHERS => '0');
			    Index_bit <= '0';
			    Imm_bit <= '0';
			    ImmediateValue_out <= (OTHERS => '0');
			    InValue_out <= (OTHERS => '0');
				PC_out <= (OTHERS => '0');
				
			END IF;
		END IF;
		
	END PROCESS;


END ARCHITECTURE;