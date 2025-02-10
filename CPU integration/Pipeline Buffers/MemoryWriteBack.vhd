LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;




ENTITY MemoryWriteBack IS
	GENERIC(
		DataWidth : INTEGER := 16; 
		InWidth :INTEGER := 16;
		SPWidth : INTEGER := 16;		
		AddressWidth : INTEGER := 3
 
	);
	PORT(
		clk : IN STD_LOGIC;
		Write_Disable : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		Flush : IN STD_LOGIC;
		
		
		
		SP_new_in 		  		: IN STD_LOGIC_VECTOR( SPWidth - 1 DOWNTO 0);		
		SP_old_out 		  		: OUT STD_LOGIC_VECTOR( SPWidth - 1 DOWNTO 0);
		
		--control signals
		-- in Blue
		
		OUT_Enable_in  : IN STD_LOGIC;
		RegW_in 	   : IN STD_LOGIC;
		
		
		OUT_Enable_out  : OUT STD_LOGIC;
		RegW_out 		: OUT STD_LOGIC;
		
		
		
		-- in Red
	    INT_in 			      : IN STD_LOGIC;
		MTR_in 	   		  	  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		Flag_Restored_in  	  : IN STD_LOGIC;
		RET_in 	   		  	  : IN STD_LOGIC;
		
		INT_out 			   : OUT STD_LOGIC;
		MTR_out 	   		   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		Flag_Restored_out  	   : OUT STD_LOGIC;
		RET_out 	   		   : OUT STD_LOGIC;
		
		ALU_In 			  : IN STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		ALU_Out			  : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);	
		
		MemoryOut_in			  : IN STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		MemoryOut_out 			  : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
		
		Index_bit_in          :  IN   STD_LOGIC;
		Index_bit_out         :  OUT STD_LOGIC;
		
		Rdst_in               : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		Rdst_out              : OUT STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
		
		InValue_in 			: IN STD_LOGIC_VECTOR( InWidth - 1 DOWNTO 0);			
		InValue_out			: OUT STD_LOGIC_VECTOR( InWidth - 1 DOWNTO 0)
	


	);
END ENTITY;


ARCHITECTURE MemoryWriteBack_Arch OF MemoryWriteBack IS 


BEGIN



	PROCESS (clk , reset)
	BEGIN
		IF reset = '1' THEN

            SP_old_out <= "0000111111111111";
            OUT_Enable_out <= '0';
            RegW_out <= '0';
            INT_out <= '0';
            MTR_out  <= "00";
            Flag_Restored_out <= '0';
            RET_out <= '0';
							  
            ALU_Out <= (OTHERS => '0');
            MemoryOut_out <= (OTHERS => '0');
            Index_bit_out <= '0';
			Rdst_out <= (OTHERS => '0');
			InValue_out <=(OTHERS => '0');
            
		ELSIF RISING_EDGE(clk) THEN
			IF Write_Disable = '0' AND Flush = '0' THEN		
				SP_old_out <= SP_new_in;
				OUT_Enable_out <= OUT_Enable_in;
				RegW_out <= RegW_in;
				INT_out <= INT_in;
				MTR_out  <= MTR_in;
				Flag_Restored_out <= Flag_Restored_in;
				RET_out <= RET_in;
								  
				ALU_Out <= ALU_In;
				MemoryOut_out <= MemoryOut_in;
				Index_bit_out <= Index_bit_in;
				Rdst_out <= Rdst_in;
				InValue_out <= InValue_in;
			
	
			ELSIF Flush = '1' THEN 
				SP_old_out <= "0000111111111111";
				OUT_Enable_out <= '0';
				RegW_out <= '0';
				INT_out <= '0';
				MTR_out  <= "00";
				Flag_Restored_out <= '0';
				RET_out <= '0';
								
				ALU_Out <= (OTHERS => '0');
				MemoryOut_out <= (OTHERS => '0');
				Index_bit_out <= '0';
				Rdst_out <= (OTHERS => '0');
				InValue_out <=(OTHERS => '0');
			
			ELSIF Write_Disable = '1' AND Flush = '0' THEN 
			--keep the values inside the register as it is no change
			
			END IF;
			
		END IF;
		
	END PROCESS;
END ARCHITECTURE;
    
