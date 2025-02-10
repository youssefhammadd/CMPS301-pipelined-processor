LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PipelinedProcessor IS
	GENERIC (
		WIDTH_12 : integer := 12;
		OpCodeWidth :INTEGER := 5;
		AddressWidth : INTEGER := 3;
		WIDTH_16 : integer := 16
	);
	
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        IN_PORT : IN STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
        OUT_PORT : OUT STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE PipelinedProcessor_Arch OF PipelinedProcessor IS

    ------------------------------------SIGNALS------------------------------------


    -- Fetch Out signals
    SIGNAL Fetch_IMM_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
    SIGNAL Fetch_IN_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
    SIGNAL Fetch_Instruction_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	SIGNAL Fetch_PC_Value_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	SIGNAL Fetch_Stall_FD_Buffer_out : STD_LOGIC;
    -- Fetch Out signals end
	
	-- FD Buffer signals
    SIGNAL FD_OpCode_out : STD_LOGIC_VECTOR(OpCodeWidth -1 DOWNTO 0);
    SIGNAL FD_Rsrc1_out : STD_LOGIC_VECTOR(AddressWidth -1 DOWNTO 0);
    SIGNAL FD_Rsrc2_out : STD_LOGIC_VECTOR(AddressWidth -1 DOWNTO 0);
    SIGNAL FD_Rdst_out : STD_LOGIC_VECTOR(AddressWidth -1 DOWNTO 0);

    SIGNAL FD_Index_bit_out : STD_LOGIC;
	SIGNAL FD_IMM_bit_out : STD_LOGIC;
    SIGNAL FD_InputPort : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	SIGNAL FD_current_IMM_value_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
    SIGNAL FD_current_PC_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);

    -- FD Buffer signals 
	
	
	--Decode Out signals
	SIGNAL Decode_PC_increment_Value_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	SIGNAL Decode_Readed_Data1 : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	SIGNAL Decode_Readed_Data2 : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	
	
	-- DE Buffer signals
    SIGNAL DE_Data1_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
    SIGNAL DE_Data2_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
    SIGNAL DE_InValue_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	SIGNAL DE_ImmediateValue_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	SIGNAL DE_PC_plus_1_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	SIGNAL DE_PC_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
    SIGNAL DE_Flag_Enable_out : STD_LOGIC;
    SIGNAL DE_Outport_enable_out : STD_LOGIC;
    SIGNAL DE_RegWrite_out : STD_LOGIC;
    SIGNAL DE_Address_out : STD_LOGIC;
    SIGNAL DE_INT_out : STD_LOGIC;
    SIGNAL DE_MemRead_out : STD_LOGIC;																	
	SIGNAL DE_MemWrite_out : STD_LOGIC;
    SIGNAL DE_MTR_out : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL DE_SPplus_SPminus_out : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL DE_Flag_Restored_out : STD_LOGIC;
    SIGNAL DE_Write_Data_Selector_out : STD_LOGIC;
    SIGNAL DE_RET_out : STD_LOGIC;
    SIGNAL DE_Z_N_C_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL DE_ALU_Selector_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    --SIGNAL DE_JMP_out : STD_LOGIC;
	SIGNAL DE_UC_out : STD_LOGIC;
    SIGNAL DE_Rd_Rs_sel_out : STD_LOGIC;
	SIGNAL DE_Rsrc1_Rsrc2_sel_out : STD_LOGIC;
	SIGNAL DE_IMM_bit_out : STD_LOGIC;
    SIGNAL DE_Index_bit_out : STD_LOGIC;
	
    SIGNAL DE_Rsrc_1_out : STD_LOGIC_VECTOR(AddressWidth -1 DOWNTO 0);
    SIGNAL DE_Rsrc_2_out : STD_LOGIC_VECTOR(AddressWidth -1 DOWNTO 0);
	SIGNAL DE_Rdst_out : STD_LOGIC_VECTOR(AddressWidth -1 DOWNTO 0);
    -- DE Buffer signals end
	
	
	
	--Execute Out signals
	SIGNAL Execute_Rdst_OUT : STD_LOGIC_VECTOR(AddressWidth -1 DOWNTO 0);
	SIGNAL Execute_ALU_result_out : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	SIGNAL Execute_Flags_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL Execute_Branch_happened_out : STD_LOGIC;
	SIGNAL Execute_Branching_Address : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	
	-- EM Buffer signals 
    SIGNAL EM_OUT_Enable_out : STD_LOGIC;
    SIGNAL EM_RegW_out : STD_LOGIC;
    SIGNAL EM_Address_out : STD_LOGIC;
    SIGNAL EM_INT_out : STD_LOGIC;
    SIGNAL EM_MemRead_out : STD_LOGIC;
    SIGNAL EM_MemWrite_out : STD_LOGIC;
    SIGNAL EM_MTR_out : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL EM_SPplus_SPminus_out : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL EM_ALU_Out : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
    SIGNAL EM_PC_out : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
	SIGNAL EM_PC_plus_1_out : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
	SIGNAL EM_PC_plus_1_with_the_Flags_out : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);	
	SIGNAL EM_InValue_out : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
	SIGNAL EM_Rdst_out : STD_LOGIC_VECTOR(AddressWidth-1 DOWNTO 0);

    SIGNAL EM_Data_1_out : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
    --SIGNAL EM_Data_2_Out : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
	  
    SIGNAL EM_Flag_Restored_out : STD_LOGIC;
    SIGNAL EM_Write_Data_Selector_out : STD_LOGIC;
    SIGNAL EM_RET_out : STD_LOGIC;
    SIGNAL EM_Index_bit_out : STD_LOGIC;
   
	
    -- EM Buffer signals end
	
	--Memory Stage Out Signals
	SIGNAL Memory_Memory_OUT : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	SIGNAL Memory_SP_new_OUT : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	SIGNAL Memory_Address_access_DM : STD_LOGIC_VECTOR(WIDTH_16 -1 DOWNTO 0);
	--SIGNAL Memory_Caused_EXP : STD_LOGIC;
	
	
	--WriteBack Stage Output
	SIGNAL WB_Chosen_Value : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
	--WriteBack IM Address 
	SIGNAL MW_PC_enters_the_fetch_stage : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
	
	-- MW Buffer signals
    SIGNAL MW_SP_old : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
    SIGNAL MW_ALU_result : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
	SIGNAL MW_Memory_out : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
	SIGNAL MW_IN_Value : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);

    SIGNAL MW_OUT_enable : STD_LOGIC;
	SIGNAL MW_RegW : STD_LOGIC;
    SIGNAL MW_MTR : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL MW_Flag_Restored : STD_LOGIC;
	SIGNAL MW_RET_signal : STD_LOGIC;
	SIGNAL MW_INT_signal_bit : STD_LOGIC;
    SIGNAL MW_Index_bit : STD_LOGIC;
    SIGNAL MW_Rdst_out : STD_LOGIC_VECTOR(AddressWidth -1 DOWNTO 0);
    -- MW Buffer signals end
	


    --FWD signals

    SIGNAL FWD_Stall_one_cycle_Out: std_logic;


    --FWD signals end
	
	--RET SIGNALS
	SIGNAL RET_Choose_DMofSP : STD_LOGIC;
	SIGNAL RET_FLUSH_FD : STD_LOGIC;
	SIGNAL RET_FLUSH_DE : STD_LOGIC;
	SIGNAL RET_FLUSH_EM : STD_LOGIC;
	
	--Prediction unit SIGNALS
	SIGNAL PredtionUnit_Flush_FD : STD_LOGIC;
	SIGNAL PredtionUnit_Flush_DE : STD_LOGIC;


	

	
	
	
	--ORing to Flush the buffers
	SIGNAL or_out_flush_FD : STD_LOGIC;
	SIGNAL or_out_flush_DE : STD_LOGIC;
	SIGNAL or_out_flush_EM : STD_LOGIC;
	SIGNAL or_out_flush_MW : STD_LOGIC;
	SIGNAL or_out_flush_Control_unit : STD_LOGIC;
	--ORing to Stall the buffers
	SIGNAL or_out_Stall_FD : STD_LOGIC;



	
	--Flush_unit outputs
	SIGNAL FlushUnit_FD : STD_LOGIC;
	SIGNAL FlushUnit_DE : STD_LOGIC;
	SIGNAL FlushUnit_EM : STD_LOGIC;
	SIGNAL FlushUnit_MW : STD_LOGIC;
	
	SIGNAL Hazard_and_Forwarding_MUX3_Selector : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL Hazard_and_Forwarding_MUX4_Selector : STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	--Exception Signals
	SIGNAL Fetch_Out_EXP_PC_value : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
    SIGNAL Fetch_Out_EXP_Write_enable : STD_LOGIC;
	SIGNAL Memory_Out_EXP_Write_enable : STD_LOGIC;
	SIGNAL Memory_Out_EXP_Chosen_Address : STD_LOGIC;
	SIGNAL Memory_Out_EXP_PC_value : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
	SIGNAL EPC_OUTPUT_ADDRESS : STD_LOGIC_VECTOR(WIDTH_16-1 DOWNTO 0);
	
	
	
	    -- Controller Signals (most of the are not connected)
    SIGNAL CTR_Flag_Enable_OUT : STD_LOGIC;
    SIGNAL CTR_ALUsel_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL CTR_MTR_OUT : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL CTR_SP_sig_OUT : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL CTR_OutPort_Enable_OUT : STD_LOGIC;
    SIGNAL CTR_RegWrite_OUT : STD_LOGIC;
    SIGNAL CTR_Address_OUT : STD_LOGIC;
    SIGNAL CTR_INT_signal_out : STD_LOGIC;
    SIGNAL CTR_MemRead_OUT : STD_LOGIC;
    SIGNAL CTR_MemWrite_OUT : STD_LOGIC;
    SIGNAL CTR_FR_OUT : STD_LOGIC;
    -- Controller for memoryData
    SIGNAL CTR_Write_Data_sel_OUT : STD_LOGIC;
    SIGNAL CTR_RET_sig_OUT : STD_LOGIC;
    SIGNAL CTR_JZ_OUT : STD_LOGIC;
    SIGNAL CTR_JN_OUT : STD_LOGIC;
    SIGNAL CTR_JC_OUT : STD_LOGIC;
    SIGNAL CTR_JMP_branch_OUT : STD_LOGIC;
    SIGNAL CTR_UC_OUT : STD_LOGIC;
    SIGNAL CTR_RdRs_sel_OUT : STD_LOGIC;
    SIGNAL CTR_Rsrc1_Rscr2_sel_OUT : STD_LOGIC;
    SIGNAL CTR_Decode_PC_disable_HLT : STD_LOGIC;
	
	
	--Temp Signals
	SIGNAL Temp_Z_N_C_CTR_SIGNAL : STD_LOGIC_VECTOR(2 DOWNTO 0); 
	SIGNAL Temp_Instruction_To_Decode_cycle : STD_LOGIC_VECTOR(15 DOWNTO 0); 
	
	
	
	
    ------------------------------------SIGNALS END-----------------------------------

BEGIN
	OUT_PORT <= 
		WB_Chosen_Value WHEN (MW_OUT_enable ='1') ELSE
		(OTHERS => '0');
	Temp_Z_N_C_CTR_SIGNAL <= CTR_JC_OUT & CTR_JN_OUT & CTR_JZ_OUT;
	Temp_Instruction_To_Decode_cycle <= FD_OpCode_out & FD_Rsrc1_out & FD_Rsrc2_out & FD_Rdst_out & FD_Index_bit_out & FD_IMM_bit_out;
	----------------------------------------------------stages integration-----------------------------------------------------------
	Fetch_Stage : ENTITY work.Integeration_Fetch  GENERIC MAP( WIDTH_12 , WIDTH_16 )     
	PORT MAP(
		Integeration_Fetch_clk => clk, 												
	    Integeration_Fetch_reset => reset,
	    Integeration_Fetch_HLT_unit_pc_disable_in => CTR_Decode_PC_disable_HLT, 	
	    Integeration_Fetch_Index_bit => MW_Index_bit , 								
	    Integeration_Fetch_INT_SIGNAL => MW_INT_signal_bit, 						
	    Integeration_Fetch_Branch_or_not => Execute_Branch_happened_out, 			
	    Exception_address_from_DM => Memory_Out_EXP_Chosen_Address, 												
	    Exception_happened_caused_by_SP => Memory_Out_EXP_Write_enable,										
	    choose_DMofSP => RET_Choose_DMofSP, 										
	    Stall_one_cycle => FWD_Stall_one_cycle_Out,									
		
	    Integeration_Fetch_Branching_Address => Execute_Branching_Address,			
	    Integeration_Fetch_DMofSP => MW_PC_enters_the_fetch_stage,					
	    IN_PORT_invalue => IN_port,													
	    Integeration_Fetch_PC_out => Fetch_PC_Value_out, --output starts
	    Integeration_Fetch_Instruction => Fetch_Instruction_out,
	    Integeration_Fetch_Imm => Fetch_IMM_out,
	    IN_PORT_outvalue => Fetch_IN_out,
	    PC_to_EPC_out => Fetch_Out_EXP_PC_value,
	    Stall_FetchDecode_Register => Fetch_Stall_FD_Buffer_out,
	    Write_to_EPC_enable => Fetch_Out_EXP_Write_enable
	);
	
	Decode_Stage : ENTITY work.decode_cycle GENERIC MAP(WIDTH_16)
	PORT MAP( 
		clk => clk,
		rst => reset,
		instruction => Temp_Instruction_To_Decode_cycle,
		pc => FD_current_PC_out,
		Write_Data_inRegFile => WB_Chosen_Value,
		Rdst_inRegFile => MW_Rdst_out,
		RegWrite_from_WB => MW_RegW,
		Flush_controlUnit => FWD_Stall_one_cycle_Out,
		Flag_Enable => CTR_Flag_Enable_OUT,
		OutPort_Enable => CTR_OutPort_Enable_OUT,
		RegWrite => CTR_RegWrite_OUT,
		Address => CTR_Address_OUT,
		INT_sig => CTR_INT_signal_out,
		MemRead => CTR_MemRead_OUT,
		MemWrite => CTR_MemWrite_OUT,
		MTR => CTR_MTR_OUT,
		SP_sig => CTR_SP_sig_OUT,
		FR => CTR_FR_OUT,
		Write_Data_sel => CTR_Write_Data_sel_OUT,
		RET_sig => CTR_RET_sig_OUT,
		JZ => CTR_JZ_OUT,
		JN => CTR_JN_OUT,
		JC => CTR_JC_OUT,
		ALU_sel => CTR_ALUsel_OUT,
		JMP_branch => CTR_JMP_branch_OUT,
		UC => CTR_UC_OUT,
		RdRs_sel => CTR_RdRs_sel_OUT,
		Rsrc1_Rscr2_sel => CTR_Rsrc1_Rscr2_sel_OUT,
		PC_disable => CTR_Decode_PC_disable_HLT,
		read_data1 => Decode_Readed_Data1,
		read_data2 => Decode_Readed_Data2,
		pc_increment => Decode_PC_increment_Value_out
	);
	
	
	Execute_Stage : ENTITY work.EXE_STAGE
	PORT MAP(	  
			 clk   => clk,
			 async_Rest_For_CCR => reset,
			
			 data_1  => DE_Data1_out,
			 data_2  => DE_Data2_out,
			 IMM     => DE_ImmediateValue_out,
			 ALU_sel => DE_ALU_Selector_out,
			 
			 H_WB_data       => WB_Chosen_Value,
			 H_EXE_MEMO_data => EM_ALU_Out,
			 FW_EXE3         => Hazard_and_Forwarding_MUX3_Selector,
			 FW_EXE4         => Hazard_and_Forwarding_MUX4_Selector,
			 
			 
			 flags_in_RTI => WB_Chosen_Value(15 DOWNTO 13),
			 ALU_F_enable => DE_Flag_Enable_out,
			 restore_WB   => MW_Flag_Restored,
			 R1_R2_sel   => DE_Rsrc1_Rsrc2_sel_out,
			 ALU_src     => DE_IMM_bit_out,
			 control_Z  => DE_Z_N_C_out(0),
		     control_N  => DE_Z_N_C_out(1),
		     control_C  => DE_Z_N_C_out(2),
			 unconditional_branching => DE_UC_out,
			 ALU_res => Execute_ALU_result_out,
			 CCR_res  => Execute_Flags_out,
			 
			 Branching_bool    => Execute_Branch_happened_out,
			 Branching_address => Execute_Branching_Address
    );
	
	
	
	Memory_Stage : ENTITY work.memory_cycle GENERIC MAP ( WIDTH_16)
	PORT MAP( 
		clk => clk,
		Rst => reset,
		ALU_res => EM_ALU_Out,
		pc_inc_withf => EM_PC_plus_1_with_the_Flags_out,
		pc_inc_withoutf => EM_PC_plus_1_out,
		Data1 => EM_Data_1_out,
		SP_old => MW_SP_old,
		INT_sig => EM_INT_out,
		MemRead => EM_MemRead_out,
		MemWrite => EM_MemWrite_out,
		SP_sig => EM_SPplus_SPminus_out,
		Write_Data_sel => EM_Write_Data_Selector_out,
		SP_new => Memory_SP_new_OUT,
		Address_enters_the_DM => Memory_Address_access_DM,
		memory_out => Memory_Memory_OUT
	);
		
	
	
	
	
	WriteBack_Stage : ENTITY work.write_back_cycle
	PORT MAP(
		Alu_Res => MW_ALU_result,			
		Mem_out => MW_Memory_out,			
        IN_port => MW_IN_Value,             
        MTR => MW_MTR,                      
        Write_back => WB_Chosen_Value       
	);
	------------------------------------------------END of Stages Integration----------------------------------------------------
	
	
	
	
	
	
	
	
	------------------------------------------------Single units in integration--------------------------------------------------
	Write_Back_Address_to_Fetch : ENTITY work.WriteBack_Value
	PORT MAP(
	Flag_Restored => MW_Flag_Restored,
	Write_Back_Value => WB_Chosen_Value,
	PC_Value => MW_PC_enters_the_fetch_stage
	);
	
	RET_UNIT : ENTITY work.RET_UNIT
	PORT MAP(
	branch_result 			=> MW_RET_signal,
	Mux_address_selector 	=> RET_Choose_DMofSP,
	Flush_fetchDecode 		=> RET_FLUSH_FD,
	Flush_decodeExecute		=> RET_FLUSH_DE,
	Flush_executeMemory 	=> RET_FLUSH_EM
	);
	
	
	Prediction_UNIT : ENTITY work.PredictionUnit
	 PORT MAP(
        branch_result       => Execute_Branch_happened_out,
        Flush_fetchDecode   => PredtionUnit_Flush_FD ,
        Flush_decodeExecute => PredtionUnit_Flush_DE 
    );
	
	
	FLUSH_UNIT : ENTITY work.FlushUnit
	PORT MAP(
        
        Exception_occurred_in_fetch   => Fetch_Out_EXP_Write_enable,
		Exception_occurred_in_Memory  => Memory_Out_EXP_Write_enable, 

        Flush_fetchDecode => FlushUnit_FD,
        Flush_decodeExecute => FlushUnit_DE,
		Flush_executeMemory=> FlushUnit_EM,
		Flush_memoryWriteBack => FlushUnit_MW
    );
	
	
	
	Hazard_and_Forwarding_Unit : ENTITY work.HazardAndForwardingUnit GENERIC MAP(AddressWidth)
    PORT MAP(
        Rsrc1_dec => FD_Rsrc1_out,
        Rsrc2_dec => FD_Rsrc2_out,
		Rsrc1_exec => DE_Rsrc_1_out,
        Rsrc2_exec => DE_Rsrc_2_out,
		Rdst_exec => Execute_Rdst_OUT,
        MemRead_exec => DE_MemRead_out,
		RegWrite_Execute => DE_RegWrite_out,
        Rdst_memory => EM_Rdst_out,
        MemRead_memory => EM_MemRead_out,
		RegWrite_memory => EM_RegW_out,
        Rdst_writeBack => MW_Rdst_out,
        RegWrite_writeBack => MW_RegW,
        Stall_one_Cycle => FWD_Stall_one_cycle_Out,
        ALU_src1_selector => Hazard_and_Forwarding_MUX3_Selector,
        ALU_src2_selector => Hazard_and_Forwarding_MUX4_Selector
    );
	
	
	Exception_Handler_Memory_Unit : ENTITY work.ExceptionHandlerMemory GENERIC MAP( WIDTH_16 ,WIDTH_16 )

	PORT MAP(
		  clk => clk,
		  Can_Cause_Exception => EM_Address_out,
		  SP_plus_SP_minus => EM_SPplus_SPminus_out,
		  SP_new_in => Memory_Address_access_DM,
		  SP_old_in => MW_SP_old,
		  PC_in => EM_PC_out,
		  PC_out => Memory_Out_EXP_PC_value,
		 
		  Exception_Chosen_Address => Memory_Out_EXP_Chosen_Address,
		  Exception_occurred => Memory_Out_EXP_Write_enable	  
	);

	
	
	EPC_Unit : ENTITY work.EPC_Unit
	PORT MAP(
		rst => reset,
		Write_Enable_From_DM => Memory_Out_EXP_Write_enable,
		Write_Enable_From_IM => Fetch_Out_EXP_Write_enable,
		PC_From_Fetch => Fetch_Out_EXP_PC_value ,
		PC_From_Memory => Memory_Out_EXP_PC_value,
		PC_caused_exception => EPC_OUTPUT_ADDRESS
	);
	
	
	
	
	
	
	
	------------------------------------------------END of Single units in integration---------------------------------------------
	
	------------------------------------------------PipeLined Buffers--------------------------------------------------
	FetchDecodeBuffer : ENTITY work.FetchDecode GENERIC MAP( WIDTH_16 , WIDTH_16 , WIDTH_16 ,WIDTH_16 , OpCodeWidth , AddressWidth)
	PORT MAP(
		clk => clk,
		Write_Disable => or_out_Stall_FD,                   
		Flush => or_out_flush_FD,                                       
		reset => reset,                           
		Instruction => Fetch_Instruction_out,               
		ImmediateValue_in => Fetch_IMM_out,                 
		InValue_in => Fetch_IN_out,                         
		PC_in => Fetch_PC_Value_out,                        
		OpCode => FD_OpCode_out,  --output                              
		Rsrc1_Address => FD_Rsrc1_out,
		Rsrc2_Address => FD_Rsrc2_out,
		Rdst_Address  => FD_Rdst_out,
		Index_bit => FD_Index_bit_out,
		Imm_bit => FD_IMM_bit_out,
		ImmediateValue_out => FD_current_IMM_value_out,
		PC_out => FD_current_PC_out,
		InValue_out => FD_InputPort
	);		
	
	DecodeExecuteBuffer : ENTITY work.DecodeExecute GENERIC MAP( WIDTH_16 , WIDTH_16 , WIDTH_16 , AddressWidth)
	PORT MAP(
		clk => clk,
		Write_Disable => '0',
		reset => reset,
		Flush => or_out_flush_DE,
		Flag_Enable_in => CTR_Flag_Enable_OUT,
		OUT_Enable_in  => CTR_OutPort_Enable_OUT,
		RegW_in 	   => CTR_RegWrite_OUT,
		Address_in 	   => CTR_Address_OUT,
		Flag_Enable_out => DE_Flag_Enable_out,
		OUT_Enable_out  => DE_Outport_enable_out,
		RegW_out 		=> DE_RegWrite_out,
		Address_out 	=> DE_Address_out,
	    INT_in 			    	=> CTR_INT_signal_out,
		MR_in  			   	    => CTR_MemRead_OUT,
		MW_in 	   		  	    => CTR_MemWrite_OUT,
		MTR_in 	   		  	    => CTR_MTR_OUT,
		SPplus_SPminus_in 	    => CTR_SP_sig_OUT,
		Flag_Restored_in  	    => CTR_FR_OUT,
		Write_Data_Selector_in  => CTR_Write_Data_sel_OUT,
		RET_in 	   		  	    => CTR_RET_sig_OUT,
		INT_out 			    => DE_INT_out,
		MR_out  			    => DE_MemRead_out,
		MW_out 	   		  	    => DE_MemWrite_out,
		MTR_out 	   		    => DE_MTR_out,
		SPplus_SPminus_out 	    => DE_SPplus_SPminus_out,
		Flag_Restored_out  	    => DE_Flag_Restored_out,
		Write_Data_Selector_out => DE_Write_Data_Selector_out,
		RET_out 	   		    => DE_RET_out,
		Z_N_C_in 	   		=> Temp_Z_N_C_CTR_SIGNAL,
		ALU_Selector_in 	=> CTR_ALUsel_OUT,
		JMP_in  		 	=> CTR_JMP_branch_OUT,
		UC_in 	   		  	=> CTR_UC_OUT,
		Rd_Rs_sel_in  	    => CTR_RdRs_sel_OUT,
		Rsrc1_Rsrc2_sel_in  => CTR_Rsrc1_Rscr2_sel_OUT,

		Z_N_C_out 	   		=> DE_Z_N_C_out,
		ALU_Selector_out 	=> DE_ALU_Selector_out,
		JMP_out  		 	=> OPEN,
		UC_out 	   		  	=> DE_UC_out,
		Rd_Rs_sel_out  	    => DE_Rd_Rs_sel_out,
		Rsrc1_Rsrc2_sel_out => DE_Rsrc1_Rsrc2_sel_out,
		IMM_bit_in          => FD_IMM_bit_out,
		IMM_bit_out         => DE_IMM_bit_out,
		Index_bit_in        => FD_Index_bit_out,
		Index_bit_out       => DE_Index_bit_out,
		Data_1_In			=> Decode_Readed_Data1,
		Data_2_In 			=> Decode_Readed_Data2,
		Data_1_Out 			=> DE_Data1_out,
		Data_2_Out			=> DE_Data2_out,
		Rsrc_1_in 			=> FD_Rsrc1_out,
		Rsrc_2_in			=> FD_Rsrc2_out,
		Rdst_in     		=> FD_Rdst_out,
		Rsrc_1_out 			=> DE_Rsrc_1_out,
		Rsrc_2_out 			=> DE_Rsrc_2_out,
		Rdst_out    		=> DE_Rdst_out,	
		ImmediateValue_in   => FD_current_IMM_value_out,
		ImmediateValue_out  => DE_ImmediateValue_out,
		PC_in 		  		=> FD_current_PC_out,
		PC_out 		  		=> DE_PC_out,	
		PC_plus_1_in  		=> Decode_PC_increment_Value_out,
		PC_plus_1_out 		=> DE_PC_plus_1_out,
		InValue_in 			=> FD_InputPort,	
		InValue_out			=> DE_InValue_out
	);
	
	
	ExecuteMemory_Buffer : ENTITY work.ExecuteMemory GENERIC MAP( WIDTH_16 , WIDTH_16 , WIDTH_16 , AddressWidth)
	PORT MAP(
		clk => clk,
		Write_Disable => '0',
		reset => reset,
		Flush => or_out_flush_EM,

		OUT_Enable_in => DE_Outport_enable_out,
		RegW_in 	  => DE_RegWrite_out,
		Address_in 	  => DE_Address_out,
		
		OUT_Enable_out  => EM_OUT_Enable_out,
		RegW_out 		=> EM_RegW_out,
		Address_out 	=> EM_Address_out,

	    INT_in 			       => DE_INT_out,
		MR_in  			   	   => DE_MemRead_out,
		MW_in 	   		  	   => DE_MemWrite_out,
		MTR_in 	   		  	   => DE_MTR_out,
		SPplus_SPminus_in 	   => DE_SPplus_SPminus_out,
		Flag_Restored_in  	   => DE_Flag_Restored_out,
		Write_Data_Selector_in => DE_Write_Data_Selector_out,
		RET_in 	   		  	   => DE_RET_out,
		
		INT_out 			    => EM_INT_out,
		MR_out  			    => EM_MemRead_out,
		MW_out 	   		  	    => EM_MemWrite_out,
		MTR_out 	   		    => EM_MTR_out,
		SPplus_SPminus_out 	    => EM_SPplus_SPminus_out,
		Flag_Restored_out  	    => EM_Flag_Restored_out,
		Write_Data_Selector_out => EM_Write_Data_Selector_out,
		RET_out 	   		    => EM_RET_out,
		
		Data_1_In			  => DE_Data1_out,
		Data_2_In 			  => DE_Data2_out,
		Data_1_Out 			  => EM_Data_1_out,
		Data_2_Out			  => OPEN,
		
		Flags => Execute_Flags_out,
		
		ALU_In 			  => Execute_ALU_result_out,
		ALU_Out			  => EM_ALU_Out,	

		Index_bit_in => DE_Index_bit_out,
		Index_bit_out   => EM_Index_bit_out,
		
		PC_in => DE_PC_out,		
		PC_out 		=> EM_PC_out,
		
		PC_plus_1_in => DE_PC_plus_1_out,		
		PC_plus_1_out => EM_PC_plus_1_out,
		PC_plus_1_with_the_Flags_out => EM_PC_plus_1_with_the_Flags_out,
		
		Rdst_in => Execute_Rdst_OUT,
		Rdst_out  => EM_Rdst_out,
		
		
		InValue_in 	=> DE_InValue_out,			
		InValue_out	=> EM_InValue_out
	);
	
	
	
	
	MemoryWriteBack_Buffer : ENTITY work.MemoryWriteBack
	PORT MAP(
		clk				  => clk,
		Write_Disable	  => '0', 
		reset             => reset,
		Flush             => or_out_flush_MW,
		SP_new_in         => Memory_SP_new_OUT,
		SP_old_out        => MW_SP_old,

		OUT_Enable_in     => EM_OUT_Enable_out,
		RegW_in           => EM_RegW_out,
 
		OUT_Enable_out    => MW_OUT_enable,
		RegW_out          => MW_RegW,

		INT_in            => EM_INT_out,
		MTR_in            => EM_MTR_out,
		Flag_Restored_in  => EM_Flag_Restored_out,
		RET_in            => EM_RET_out,

		INT_out           => MW_INT_signal_bit,
		MTR_out           => MW_MTR,
		Flag_Restored_out => MW_Flag_Restored,
		RET_out           => MW_RET_signal,

		ALU_In            => EM_ALU_Out,
		ALU_Out           => MW_ALU_result,

		MemoryOut_in      => Memory_Memory_OUT,
		MemoryOut_out     => MW_Memory_out,

		Index_bit_in      => EM_Index_bit_out,
		Index_bit_out     => MW_Index_bit,

		Rdst_in           => EM_Rdst_out,
		Rdst_out          => MW_Rdst_out,

		InValue_in        => EM_InValue_out,
		InValue_out       => MW_IN_Value
	
	);
	------------------------------------------------END of PipeLined Buffers--------------------------------------------------
	
	
	
	
	
	
	
	------------------------------------------------OR's For Flushing and Stalling--------------------------------------------------
	ORing_to_disable_the_FD_buffer : ENTITY work.OR_2_inputs
	PORT MAP(
		A => Fetch_Stall_FD_Buffer_out,
		B => FWD_Stall_one_cycle_Out,
		Y => or_out_Stall_FD
	);
	ORing_5inputs_to_flush_FD_buffer : ENTITY work.OR_5
	PORT MAP(
		A => '0',
		B => FlushUnit_FD,
		C => RET_FLUSH_FD,
		D => PredtionUnit_Flush_FD,
		E => CTR_Decode_PC_disable_HLT,
		Y => or_out_flush_FD
	);
	
	
	ORing_5inputs_to_flush_DE_buffer : ENTITY work.OR_5
	PORT MAP(
		A => '0',
		B => FlushUnit_DE,
		C => RET_FLUSH_DE,
		D => PredtionUnit_Flush_DE,
		E => '0',
		Y => or_out_flush_DE
	);
	
	
	
	ORing_5inputs_to_flush_EM_buffer : ENTITY work.OR_5
	PORT MAP(
		A => '0',
		B => FlushUnit_EM,
		C => RET_FLUSH_EM,
		D => '0',
		E => '0',
		Y => or_out_flush_EM
	);
	
	ORing_the_reset_and_flush_of_MW_buffer : ENTITY work.OR_2_inputs
	PORT MAP(
        A => '0',
        B => FlushUnit_MW,
        Y => or_out_flush_MW
    );
	
	
	ORing_to_reset_control_signals : ENTITY work.OR_2_inputs
	PORT MAP(
        A => reset,
        B => FWD_Stall_one_cycle_Out,
        Y => or_out_flush_Control_unit
    );
	 

	

	------------------------------------------------END of OR's For Flushing--------------------------------------------------
	
	
	------------------------------------------------MUX's USED--------------------------------------------------
	
	MUX_to_choose_bet_Rdst_and_Rsrc1 : ENTITY work.MUX_2to1 GENERIC MAP( AddressWidth)
	PORT MAP(
		sel => DE_Rd_Rs_sel_out,
		A => DE_Rsrc_1_out,
		B => DE_Rdst_out,
		Y => Execute_Rdst_OUT
	);
	
	
	
	
	------------------------------------------------END MUX's USED--------------------------------------------------

END ARCHITECTURE;
