LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY HazardAndForwardingUnit IS
	generic (
		RegisterAdrres_width : integer := 3
	);
    PORT (
        
		--Rsrc1 Decode
        Rsrc1_dec : IN STD_LOGIC_VECTOR(RegisterAdrres_width-1 DOWNTO 0);
		--Rsrc2 Decode
        Rsrc2_dec : IN STD_LOGIC_VECTOR(RegisterAdrres_width-1 DOWNTO 0);
		

		
		
		Rsrc1_exec : IN STD_LOGIC_VECTOR(RegisterAdrres_width-1 DOWNTO 0);
        Rsrc2_exec : IN STD_LOGIC_VECTOR(RegisterAdrres_width-1 DOWNTO 0);
		Rdst_exec : IN STD_LOGIC_VECTOR(RegisterAdrres_width-1 DOWNTO 0);
        MemRead_exec : IN STD_LOGIC;
		RegWrite_Execute : IN STD_LOGIC;
        


        Rdst_memory : IN STD_LOGIC_VECTOR(RegisterAdrres_width-1 DOWNTO 0);
        MemRead_memory : IN STD_LOGIC;
		RegWrite_memory : IN STD_LOGIC;



        Rdst_writeBack : IN STD_LOGIC_VECTOR(RegisterAdrres_width-1 DOWNTO 0);
        RegWrite_writeBack : IN STD_LOGIC;

   
        Stall_one_Cycle : OUT STD_LOGIC; -- Load Use case
		
        ALU_src1_selector : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        ALU_src2_selector : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END ENTITY ;

ARCHITECTURE HazardAndForwardingUnit_Arch OF HazardAndForwardingUnit IS
BEGIN

    ALU_src1_selector <= 
        "00" WHEN (RegWrite_memory = '1' AND Rdst_memory = Rsrc1_exec ) ELSE
        "10" WHEN (RegWrite_writeBack = '1' AND Rdst_writeBack = Rsrc1_exec  AND NOT (RegWrite_memory = '1' AND Rdst_memory = Rsrc1_exec) ) 
        ELSE "01";

    ALU_src2_selector <= 
        "00" WHEN (RegWrite_memory = '1' AND Rdst_memory = Rsrc2_exec ) ELSE
        "10" WHEN (RegWrite_writeBack = '1' AND Rdst_writeBack = Rsrc2_exec  AND NOT (RegWrite_memory = '1'  AND Rdst_memory = Rsrc2_exec)) 
        ELSE "01";

    Stall_one_Cycle <= '0' ;
		--'1' WHEN (((Rsrc1_dec = Rdst_exec ) OR (Rsrc2_dec = Rdst_exec)) AND ((MemRead_exec = '1'))) 	
		--ELSE '0';

 
END ARCHITECTURE;

