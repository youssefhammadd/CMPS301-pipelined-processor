LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;


ENTITY Integeration_Fetch is

	GENERIC (
		WIDTH_12 : integer := 12;
		WIDTH_16 : integer := 16
	);

	PORT (
		  Integeration_Fetch_clk,
		  Integeration_Fetch_reset,
		  Integeration_Fetch_HLT_unit_pc_disable_in,
		  Integeration_Fetch_Index_bit,
		  Integeration_Fetch_INT_SIGNAL,
		  Integeration_Fetch_Branch_or_not,
		  Exception_address_from_DM,
		  Exception_happened_caused_by_SP,
		  choose_DMofSP,
		  Stall_one_cycle: IN  STD_LOGIC;
		  Integeration_Fetch_Branching_Address,
		  Integeration_Fetch_DMofSP,
		  IN_PORT_invalue : IN STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
		  PC_old_value_from_decode : IN STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 ) := (others => '0');
		  
		  Integeration_Fetch_PC_out : OUT STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
		  
		  Integeration_Fetch_Instruction ,
		  Integeration_Fetch_Imm,
		  IN_PORT_outvalue,
		  PC_to_EPC_out: OUT STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
		  
		  Stall_FetchDecode_Register,
		  Write_to_EPC_enable : OUT STD_LOGIC
		  
	);

END ENTITY;


ARCHITECTURE Integeration_Fetch_arch of Integeration_Fetch is

	SIGNAL Address_of_Exception_from_IM : STD_LOGIC;
	SIGNAL Exception_address_selector : STD_LOGIC;
	SIGNAL Exception_happened : STD_LOGIC;
	SIGNAL Exception_happened_caused_by_PC : STD_LOGIC;
	SIGNAL Integeration_Fetch_PC_disable_HLT : STD_LOGIC;
	SIGNAL Integeration_Fetch_one_cycle_delayed : STD_LOGIC;
	SIGNAL Integeration_Fetch_delay_one_cycle : STD_LOGIC;
	SIGNAL Integeration_Fetch_Disable_the_PC : STD_LOGIC;
	
	SIGNAL Addition_pc_value_Selector : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	
	SIGNAL INSTRUCTION_value : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	
	SIGNAL Integeration_Fetch_Instruction_IMM_bit : STD_LOGIC;
	SIGNAL Integeration_Fetch_pc_address_out : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	
	SIGNAL MUX2to1_PCincrement_or_IMofIndexPlus3_choice : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	SIGNAL MUX2to1_previousMUX_or_branchAddress_choice : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	SIGNAL MUX2to1_Exception_choice : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	SIGNAL MUX2to1_Exception_or_previousMUXorBranchAddress_choice : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	SIGNAL MUX2to1_DMofSP_or_previousMUX_choice : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	
	SIGNAL Integeration_Fetch_pc_Adder_Results : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	SIGNAL Integeration_Fetch_MUX_2to1_Choice_to_pc : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	SIGNAL Integeration_Fetch_MUX_2to1_Choice_index_and_pc : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	SIGNAL Integeration_Fetch_index_Adder_Results : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	SIGNAL Integeration_Fetch_index_Adder_Results_plus_IM_of_3 : STD_LOGIC_VECTOR( WIDTH_16-1 DOWNTO 0 );
	
BEGIN
	IN_PORT_outvalue <= IN_PORT_invalue;
	Integeration_Fetch_PC_out <= Integeration_Fetch_pc_address_out;
	
	Integeration_Fetch_Instruction <= INSTRUCTION_value;
	Write_to_EPC_enable <= Exception_happened_caused_by_PC;
	
	--instruction memory(done)
	
	InstructionMemory : ENTITY work.InstructionMemory 
	PORT MAP(
	InstructionMemory_address_in_Bus => Integeration_Fetch_pc_address_out(WIDTH_12-1 DOWNTO 0 ),
	InstructionMemory_Imm_Bit =>  Integeration_Fetch_Instruction_IMM_bit,
	InstructionMemory_Instruction_Bus => INSTRUCTION_value ,
	InstructionMemory_Imm_Bus => Integeration_Fetch_Imm
	);
	Addition_pc_value_Selector <= Stall_one_cycle & Integeration_Fetch_Instruction_IMM_bit ;
	
	MUX4to1_pc_inc_1_or_2_or_0 : ENTITY work.MUX_4to1 GENERIC MAP (WIDTH_16)
    PORT MAP(
        Sel => Addition_pc_value_Selector,
        A => "0000000000000001",
	    B => "0000000000000010",
		C => "0000000000000000",
		D => "0000000000000000",
        Y => Integeration_Fetch_MUX_2to1_Choice_to_pc
    );
	

	
	--takes the output from the mux that chooses 1 or 2 and add it with the PC
	Adding_pc :  entity work.pc_adder 
	GENERIC MAP(WIDTH_16) 
	PORT MAP( 
	pc_adder_address_out => Integeration_Fetch_pc_address_out,
	pc_adder_src2 => Integeration_Fetch_MUX_2to1_Choice_to_pc,
	pc_adder_summation => Integeration_Fetch_pc_Adder_Results
	);
	
	
	
	--PC entity (done)
	PC_label : ENTITY work.PC 
	PORT MAP(
	pc_clk => Integeration_Fetch_clk,
	pc_reset => Integeration_Fetch_reset ,
	pc_disable => Integeration_Fetch_Disable_the_PC ,
	pc_address_in => Integeration_Fetch_MUX_2to1_Choice_index_and_pc,
	pc_address_out => Integeration_Fetch_pc_address_out
	);
	
	TwoInputOR_for_PC_Freeze: ENTITY work.OR_2_inputs
	PORT MAP(
	A => Stall_one_cycle,--input come from the forwarding unit
	B => Integeration_Fetch_PC_disable_HLT, --input come from the HLT unit
	Y => Integeration_Fetch_Disable_the_PC
	);
	
	--chooses between index+3 or PC+1 or PC + 2
	MUX2to1_Lastone : ENTITY work.MUX_2to1 GENERIC MAP(WIDTH_16) 
	PORT MAP(
	Sel => Integeration_Fetch_INT_SIGNAL,
	A  => MUX2to1_DMofSP_or_previousMUX_choice, -- to choose pc+1 or pc+2
	B =>  Integeration_Fetch_index_Adder_Results_plus_IM_of_3, -- to choose the IM[address]
	Y => Integeration_Fetch_MUX_2to1_Choice_index_and_pc
	);
	
	

	
	
	Adding_index :  entity work.index_adder 
	GENERIC MAP(WIDTH_16) 
	PORT MAP( 
	index_bit => Integeration_Fetch_Index_bit,
	index_adder_summation => Integeration_Fetch_index_Adder_Results_plus_IM_of_3
	);
	
	
	
	
	
	-- It's output is 1 if the input is 1 and output keeps equal to one until a reset
	HLT_unit :  entity work.HLT_unit  
	PORT MAP( 
	HLT_unit_pc_disable_in => Integeration_Fetch_HLT_unit_pc_disable_in,
	HLT_unit_reset => Integeration_Fetch_reset,
	HLT_unit_pc_disable_out => Integeration_Fetch_PC_disable_HLT
	);
	
	
	--OR which it's output enters the fetch decode register
	Out_stall_one_cycle : ENTITY work.OR_2_inputs  
	PORT MAP(
	A  => Integeration_Fetch_PC_disable_HLT,
	B =>  Integeration_Fetch_delay_one_cycle, 
	Y => Stall_FetchDecode_Register -- output to the Fetch Decode Register to stall it
	);
	
	
	
	ThreeInputOR_INT_Reset_ExceptionOccurred: ENTITY work.ThreeInputOR
	PORT MAP(
	A => Integeration_Fetch_INT_SIGNAL,
	B => Integeration_Fetch_reset,
	C => Exception_happened,
	Y => Integeration_Fetch_delay_one_cycle
	);
	
	DFF : ENTITY work.DFF_entity  
	PORT MAP(
	clk => Integeration_Fetch_clk,
	D =>  Integeration_Fetch_delay_one_cycle, 
	Q => Integeration_Fetch_one_cycle_delayed
	);
	
	
	MUX2to1_PCincrement_or_IMofAddress : ENTITY work.MUX_2to1 GENERIC MAP(WIDTH_16) 
	PORT MAP(
	Sel => Integeration_Fetch_one_cycle_delayed,
	A  => Integeration_Fetch_pc_Adder_Results, -- to choose pc+1 or pc+2 
	B =>  INSTRUCTION_value(WIDTH_16-1 DOWNTO 0), --IM[index+3] 
	Y => MUX2to1_PCincrement_or_IMofIndexPlus3_choice
	);
	
	MUX2to1_previousMUX_or_branchAddress : ENTITY work.MUX_2to1 GENERIC MAP(WIDTH_16) 
	PORT MAP(
	Sel => Integeration_Fetch_Branch_or_not,
	A  => MUX2to1_PCincrement_or_IMofIndexPlus3_choice,  
	B =>  Integeration_Fetch_Branching_Address(WIDTH_16-1 DOWNTO 0), 
	Y => MUX2to1_previousMUX_or_branchAddress_choice
	);
	
	
	
	
	TwoInputOR_for_Address_Mux_selector: ENTITY work.OR_2_inputs
	PORT MAP(
	A => Address_of_Exception_from_IM,--input come from the forwarding unit
	B => Exception_address_from_DM, --input come from the HLT unit
	Y => Exception_address_selector
	);
	
	
	
	
	
	MUX2to1_Exception : ENTITY work.MUX_2to1 GENERIC MAP(WIDTH_16) 
	PORT MAP(
	Sel => Exception_address_selector,
	A  => "0000000000000001",  --address 1
	B =>  "0000000000000010",  --address 2
	Y => MUX2to1_Exception_choice
	);
	
	
	TwoInputOR_for_Mux_Selector: ENTITY work.OR_2_inputs
	PORT MAP(
	A => Exception_happened_caused_by_SP,--input come from the forwarding unit
	B => Exception_happened_caused_by_PC, --input come from the HLT unit
	Y => Exception_happened
	);
	
	
	MUX2to1_Exception_or_previousMUXorBranchAddress : ENTITY work.MUX_2to1 GENERIC MAP(WIDTH_16) 
	PORT MAP(
	Sel => Exception_happened,
	A  => MUX2to1_previousMUX_or_branchAddress_choice,  
	B =>  MUX2to1_Exception_choice,  --address 1 or address 2
	Y => MUX2to1_Exception_or_previousMUXorBranchAddress_choice
	);
	
	MUX2to1_DMofSP_or_previousMUX : ENTITY work.MUX_2to1 GENERIC MAP(WIDTH_16) 
	PORT MAP(
	Sel => choose_DMofSP,
	A  => MUX2to1_Exception_or_previousMUXorBranchAddress_choice,  --address 1
	B =>  Integeration_Fetch_DMofSP(WIDTH_16-1 DOWNTO 0),  --address 2
	Y => MUX2to1_DMofSP_or_previousMUX_choice
	);

	
	
	
	
	Exception_handler : ENTITY work.ExceptionHandlerFetch GENERIC MAP(WIDTH_16) 
	PORT MAP(
	PC_disabled_or_not => Integeration_Fetch_Disable_the_PC,
	PC_in_to_IM => Integeration_Fetch_pc_address_out , 
	PC_old_in => PC_old_value_from_decode,
	PC_to_EPC => PC_to_EPC_out,
	Exception_Chosen_Address => Address_of_Exception_from_IM,
	Exception_occurred => Exception_happened_caused_by_PC
	);
	
	
	
	
END ARCHITECTURE;