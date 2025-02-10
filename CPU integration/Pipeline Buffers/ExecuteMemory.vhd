LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;




ENTITY ExecuteMemory IS
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
		
		OUT_Enable_in  : IN STD_LOGIC;
		RegW_in 	   : IN STD_LOGIC;
		Address_in 	   : IN STD_LOGIC;
		
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
		
		Data_1_In			  : IN STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		Data_2_In 			  : IN STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		Data_1_Out 			  : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		Data_2_Out			  : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		
		Flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		
		ALU_In 			  : IN STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		ALU_Out			  : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);	
		
		

	
		
		
		Index_bit_in          :  IN   STD_LOGIC;
		Index_bit_out         :  OUT STD_LOGIC;
		
		PC_in 		  		: IN STD_LOGIC_VECTOR( PcWidth - 1 DOWNTO 0);		
		PC_out 		  		: OUT STD_LOGIC_VECTOR( PcWidth - 1 DOWNTO 0);
		
		PC_plus_1_in  		: IN STD_LOGIC_VECTOR( PcWidth - 1 DOWNTO 0);		
		PC_plus_1_out 		: OUT STD_LOGIC_VECTOR( PcWidth - 1 DOWNTO 0);
		PC_plus_1_with_the_Flags_out : OUT STD_LOGIC_VECTOR( PcWidth - 1 DOWNTO 0);
		
		Rdst_in               : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		Rdst_out              : OUT STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		
		
		InValue_in 			: IN STD_LOGIC_VECTOR( InWidth - 1 DOWNTO 0);			
		InValue_out			: OUT STD_LOGIC_VECTOR( InWidth - 1 DOWNTO 0)
	


	);
END ENTITY;


ARCHITECTURE ExecuteMemory_Arch OF ExecuteMemory IS 


BEGIN



	PROCESS (clk , reset)
	BEGIN
		IF reset = '1' THEN

			
			
			OUT_Enable_out <= '0';
			RegW_out <= '0';
			Address_out <= '0';

			INT_out <= '0';
			MR_out <= '0';
			MW_out <= '0';
			MTR_out <= "00";
			SPplus_SPminus_out <= "00";
			Flag_Restored_out <= '0';
			Write_Data_Selector_out <= '0';
			RET_out <= '0';

			Data_1_Out <= (OTHERS =>'0');
			Data_2_Out <= (OTHERS =>'0');
			ALU_Out <= (OTHERS =>'0');

			
			Index_bit_out <= '0';
			PC_out <= (OTHERS =>'0');		
			PC_plus_1_out<= (OTHERS =>'0');
			PC_plus_1_with_the_Flags_out <= (OTHERS =>'0');

			Rdst_out <= (OTHERS =>'0');
			InValue_out <= (OTHERS =>'0');
			

		ELSIF RISING_EDGE(clk) THEN
			IF Write_Disable = '0' AND Flush = '0' THEN		
				OUT_Enable_out <= OUT_Enable_in;
				RegW_out <= RegW_in;
				Address_out <= Address_in;
				INT_out <= INT_in;
				MR_out <= MR_in;
				MW_out <= MW_in;
				MTR_out <= MTR_in;
				SPplus_SPminus_out <= SPplus_SPminus_in;
				Flag_Restored_out <= Flag_Restored_in;
				Write_Data_Selector_out <= Write_Data_Selector_in;
				RET_out <= RET_in;
				
				Data_1_Out <= Data_1_In;
				Data_2_Out <= Data_2_In;
				ALU_Out <= ALU_In;
				Index_bit_out <= Index_bit_in;
				PC_out <= PC_in;
				PC_plus_1_out <= PC_plus_1_in;
				PC_plus_1_with_the_Flags_out <= Flags(2) & Flags(1) & Flags(0) & PC_plus_1_in(12 DOWNTO 0);
				Rdst_out <= Rdst_in;
				InValue_out <= InValue_in;
	
			ELSIF Flush = '1' THEN 
				OUT_Enable_out <= '0';
				RegW_out <= '0';
				Address_out <= '0';
	
				INT_out <= '0';
				MR_out <= '0';
				MW_out <= '0';
				MTR_out <= "00";
				SPplus_SPminus_out <= "00";
				Flag_Restored_out <= '0';
				Write_Data_Selector_out <= '0';
				RET_out <= '0';
	
				Data_1_Out <= (OTHERS =>'0');
				Data_2_Out <= (OTHERS =>'0');
				ALU_Out <= (OTHERS =>'0');
	
				
				Index_bit_out <= '0';
				PC_out <= (OTHERS =>'0');		
				PC_plus_1_out<= (OTHERS =>'0');
				PC_plus_1_with_the_Flags_out <= (OTHERS =>'0');
	
				Rdst_out <= (OTHERS =>'0');
				InValue_out <= (OTHERS =>'0');
			
			ELSIF Write_Disable = '1' AND Flush = '0' THEN 
			--keep the values inside the register as it is no change
			
			END IF;
			
		END IF;
		
	END PROCESS;
END ARCHITECTURE;
    
