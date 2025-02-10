LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;




ENTITY DecodeExecute IS
	GENERIC(
		DataWidth : INTEGER := 16; 
		InWidth :INTEGER := 16;
		PcWidth : INTEGER := 16;		
		AddressWidth : INTEGER := 3
 
	);
	PORT(
		clk : IN STD_LOGIC;
		Write_Disable : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		Flush : IN STD_LOGIC;
		
		
		--control signals
		-- in Blue
		Flag_Enable_in : IN STD_LOGIC;
		OUT_Enable_in  : IN STD_LOGIC;
		RegW_in 	   : IN STD_LOGIC;
		Address_in 	   : IN STD_LOGIC;
		
		Flag_Enable_out : OUT STD_LOGIC;
		OUT_Enable_out  : OUT STD_LOGIC;
		RegW_out 		: OUT STD_LOGIC;
		Address_out 	: OUT STD_LOGIC;
		
		
		-- in Red
	    INT_in 			      : IN STD_LOGIC;
		MR_in  			   	  : IN STD_LOGIC;
		MW_in 	   		  	  : IN STD_LOGIC;
		MTR_in 	   		  	  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		SPplus_SPminus_in 	  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		Flag_Restored_in  	  : IN STD_LOGIC;
		Write_Data_Selector_in: IN STD_LOGIC;
		RET_in 	   		  	  : IN STD_LOGIC;
		
		INT_out 			   : OUT STD_LOGIC;
		MR_out  			   : OUT STD_LOGIC;
		MW_out 	   		  	   : OUT STD_LOGIC;
		MTR_out 	   		   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		SPplus_SPminus_out 	   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		Flag_Restored_out  	   : OUT STD_LOGIC;
		Write_Data_Selector_out: OUT STD_LOGIC;
		RET_out 	   		   : OUT STD_LOGIC;
		
		
		-- in Green
		Z_N_C_in 	   		  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		ALU_Selector_in 	  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		JMP_in  		 	  : IN STD_LOGIC;
		UC_in 	   		  	  : IN STD_LOGIC;
		Rd_Rs_sel_in  	      : IN STD_LOGIC;
		Rsrc1_Rsrc2_sel_in    : IN STD_LOGIC;

		Z_N_C_out 	   		  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		ALU_Selector_out 	  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		JMP_out  		 	  : OUT STD_LOGIC;
		UC_out 	   		  	  : OUT STD_LOGIC;
		Rd_Rs_sel_out  	      : OUT STD_LOGIC;
		Rsrc1_Rsrc2_sel_out   : OUT STD_LOGIC;
		
		
		
		--used rather than ALU src because it do the same functionality
		IMM_bit_in            :  IN   STD_LOGIC;
		IMM_bit_out           :  OUT STD_LOGIC;
		
		
		Index_bit_in          :  IN   STD_LOGIC;
		Index_bit_out         :  OUT STD_LOGIC;
		
		--data abd addresses of the registers
		Data_1_In			  : IN STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		Data_2_In 			  : IN STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		
		
		Data_1_Out 			  : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		Data_2_Out			  : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		
		
		Rsrc_1_in 			  : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		Rsrc_2_in			  : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		Rdst_in               : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		
		
		Rsrc_1_out 			  : OUT STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		Rsrc_2_out 			  : OUT STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		Rdst_out              : OUT STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		
		
		ImmediateValue_in     : IN STD_LOGIC_VECTOR( DataWidth - 1 DOWNTO 0);
		
		ImmediateValue_out    : OUT STD_LOGIC_VECTOR( DataWidth - 1 DOWNTO 0);
		
		
		PC_in 		  		: IN STD_LOGIC_VECTOR( PcWidth - 1 DOWNTO 0);
				
		PC_out 		  		: OUT STD_LOGIC_VECTOR( PcWidth - 1 DOWNTO 0);
				
		PC_plus_1_in  		: IN STD_LOGIC_VECTOR( PcWidth - 1 DOWNTO 0);
				
		PC_plus_1_out 		: OUT STD_LOGIC_VECTOR( PcWidth - 1 DOWNTO 0);
		
		
		InValue_in 			: IN STD_LOGIC_VECTOR( InWidth - 1 DOWNTO 0);
					
		InValue_out			: OUT STD_LOGIC_VECTOR( InWidth - 1 DOWNTO 0)

	);
END ENTITY;


ARCHITECTURE DecodeExecute_Arch OF DecodeExecute IS 
BEGIN
	PROCESS (clk , reset)
	BEGIN
		IF reset = '1' THEN
			-- Reset all outputs to '0' when reset is active
			Address_out <= '0';
			RegW_out <= '0';
			OUT_Enable_out <= '0';
			Flag_Enable_out <= '0';
			
			
			RET_out <= '0';
			Write_Data_Selector_out <= '0';
			Flag_Restored_out <= '0';
			SPplus_SPminus_out <= "00";
			MTR_out <= "00";
			MW_out <= '0';
			MR_out <= '0';
			INT_out <= '0';                      
			
			IMM_bit_out <= '0';
			Index_bit_out <= '0';
			
			Z_N_C_out			<= "000";
			ALU_Selector_out  <= "000";
			JMP_out           <= '0';
			UC_out            <= '0';
			Rd_Rs_sel_out 		<= '0';
			Rsrc1_Rsrc2_sel_out <= '0'; 	
			
			Data_1_Out <= (OTHERS => '0');
			Data_2_Out <= (OTHERS => '0');
			Rsrc_1_out <= (OTHERS => '0');
			Rsrc_2_out <= (OTHERS => '0');
			Rdst_out <= (OTHERS => '0');
			
			ImmediateValue_out <= (OTHERS => '0');
			PC_out <= (OTHERS => '0');
			PC_plus_1_out <= (OTHERS => '0');
			InValue_out <= (OTHERS => '0');
			
		ELSIF RISING_EDGE(clk) THEN
			IF Write_Disable = '0' AND Flush = '0' THEN		
				Address_out <= Address_in;
				RegW_out <= RegW_in;
				OUT_Enable_out <= OUT_Enable_in;
				Flag_Enable_out	<= Flag_Enable_in;
				
				RET_out <= RET_in;
				Write_Data_Selector_out <= Write_Data_Selector_in;
				Flag_Restored_out <= Flag_Restored_in;
				SPplus_SPminus_out <= SPplus_SPminus_in;
				MTR_out <= MTR_in;
				MW_out <= MW_in;
				MR_out <= MR_in;
				INT_out <= INT_in;
				
				IMM_bit_out <= IMM_bit_in;
				Index_bit_out <= Index_bit_in;
				
				Z_N_C_out <= Z_N_C_in;
				ALU_Selector_out <= ALU_Selector_in;
				JMP_out <= JMP_in;
				UC_out <= UC_in;
				Rd_Rs_sel_out <= Rd_Rs_sel_in;
				Rsrc1_Rsrc2_sel_out <= Rsrc1_Rsrc2_sel_in;
				
				
				Data_1_Out <= Data_1_In;
				Data_2_Out <= Data_2_In;
				
				Rsrc_1_out <= Rsrc_1_in;
				Rsrc_2_out <= Rsrc_2_in;
				Rdst_out <= Rdst_in;
				
				ImmediateValue_out <= ImmediateValue_in;
				PC_out <= PC_in;
				PC_plus_1_out <= PC_plus_1_in;
				InValue_out <= InValue_in;
			ELSIF Flush = '1' THEN 
				-- Reset all outputs to '0' when reset is active
				Address_out <= '0';
				RegW_out <= '0';
				OUT_Enable_out <= '0';
				Flag_Enable_out <= '0';
				
				
				RET_out <= '0';
				Write_Data_Selector_out <= '0';
				Flag_Restored_out <= '0';
				SPplus_SPminus_out <= "00";
				MTR_out <= "00";
				MW_out <= '0';
				MR_out <= '0';
				INT_out <= '0';                      
				
				IMM_bit_out <= '0';
				Index_bit_out <= '0';
				
				Z_N_C_out			<= "000";
				ALU_Selector_out  <= "000";
				JMP_out           <= '0';
				UC_out            <= '0';
				Rd_Rs_sel_out 		<= '0';
				Rsrc1_Rsrc2_sel_out <= '0'; 	
				
				Data_1_Out <= (OTHERS => '0');
				Data_2_Out <= (OTHERS => '0');
				Rsrc_1_out <= (OTHERS => '0');
				Rsrc_2_out <= (OTHERS => '0');
				Rdst_out <= (OTHERS => '0');
				
				ImmediateValue_out <= (OTHERS => '0');
				PC_out <= (OTHERS => '0');
				PC_plus_1_out <= (OTHERS => '0');
				InValue_out <= (OTHERS => '0');
				
				ELSIF Write_Disable = '1' AND Flush = '0' THEN 
				--keep the values inside the register as it is no change
				
			END IF;
			
		END IF;
		
	END PROCESS;
END ARCHITECTURE;
    
