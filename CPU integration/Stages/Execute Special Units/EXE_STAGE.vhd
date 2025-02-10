LIBRARY ieee;
USE ieee.std_logic_1164.all;
  
-- TODO: add clk and UC to ccr reg
ENTITY EXE_STAGE IS 
		PORT  (	  
			
			 clk                    : in STD_LOGIC;
			 async_Rest_For_CCR  	: in STD_LOGIC;
			
			 data_1    : IN STD_LOGIC_VECTOR(15 downto 0); 
			 data_2    : IN STD_LOGIC_VECTOR(15 downto 0);
			 IMM       : IN STD_LOGIC_VECTOR(15 downto 0);
			 ALU_sel   : IN STD_LOGIC_VECTOR(2 downto 0);
			 
			 H_WB_data       : IN STD_LOGIC_VECTOR(15 downto 0); --Hazard
			 H_EXE_MEMO_data : IN STD_LOGIC_VECTOR(15 downto 0); --Hazard
			 FW_EXE3         : in STD_LOGIC_VECTOR(1 downto 0); --MUX selectors
			 FW_EXE4         : in STD_LOGIC_VECTOR(1 downto 0);
			 
			 
			 flags_in_RTI    : in STD_LOGIC_VECTOR(2 downto 0);
			  
			 ALU_F_enable    : in STD_LOGIC;
			 restore_WB      : in STD_LOGIC;
			 
			 --MUX selectors
			 R1_R2_sel       : in STD_LOGIC;
			 ALU_src         : in STD_LOGIC;
			 
			 control_Z  			       : in STD_LOGIC; --branching inputs
		    control_N  				    : in STD_LOGIC;
		    control_C                  : in STD_LOGIC;
			 unconditional_branching    : in STD_LOGIC;
			 
			 --Outputs 
			 ALU_res : OUT STD_LOGIC_VECTOR(15 downto 0);
			 CCR_res : OUT STD_LOGIC_VECTOR(2 downto 0):= (others => '0'); --condition code register (Zero, negative , carry)
			 
			 Branching_bool    : out STD_LOGIC;
			 Branching_address : OUT STD_LOGIC_VECTOR(15 downto 0)
               );
END ENTITY;

ARCHITECTURE A_EXE_STAGE OF EXE_STAGE IS
	COMPONENT ALU IS 
		PORT  (	  
			 data_1  : IN STD_LOGIC_VECTOR(15 downto 0); 
			 data_2  : IN STD_LOGIC_VECTOR(15 downto 0);
			 ALU_sel : IN STD_LOGIC_VECTOR(2 downto 0);
			 ALU_res : OUT STD_LOGIC_VECTOR(15 downto 0);
			 CCR     : OUT STD_LOGIC_VECTOR(2 downto 0):= (others => '0') --condition code register (Zero, negative , carry)
               );
	END COMPONENT;
	
	COMPONENT CCR is
    port(
			
			clk            : in STD_LOGIC;
			asyncRest		: in STD_LOGIC;
			
			unconditional_branching : in STD_LOGIC;
			
        flags_in_ALU    : in STD_LOGIC_VECTOR(2 downto 0);
        flags_in_RTI    : in STD_LOGIC_VECTOR(2 downto 0);
        reset_Z         : in STD_LOGIC;
        reset_N         : in STD_LOGIC;
        reset_C         : in STD_LOGIC;
        
        ALU_F_enable    : in STD_LOGIC;
        restore_WB      : in STD_LOGIC;
        
        flags_out       : out STD_LOGIC_VECTOR(2 downto 0)
			);
	end COMPONENT;
	
	COMPONENT MUX2to1_16bits is
    Port (
        A   : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 1
        B   : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 2
        SEL : in STD_LOGIC;      -- Select signal
        Y   : out STD_LOGIC_VECTOR(15 downto 0)        -- Output
			);
	end COMPONENT;
	
	COMPONENT MUX3to1 is
    Port (
        A : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 1
        B : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 2
        C : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 3
        SEL : in STD_LOGIC_VECTOR(1 downto 0); -- 2-bit Select signal
        Y : out STD_LOGIC_VECTOR(15 downto 0)        -- Output
			 );
		end COMPONENT;
		
		COMPONENT Branching is
			 port(
				  flags_in  					  : in STD_LOGIC_VECTOR(2 downto 0);
		 
				  control_Z        			  : in STD_LOGIC;
				  control_N        			  : in STD_LOGIC;
				  control_C                  : in STD_LOGIC;
				  
				  unconditional_branching    : in STD_LOGIC;
				  
				  Branching_bool             : out STD_LOGIC;
				  flags_out                  : out STD_LOGIC_VECTOR(2 downto 0)
			 );
		end COMPONENT;
	
 
	SIGNAL ALU_Flags      : STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL branch_Flags   : STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL CCR_actual_out : STD_LOGIC_VECTOR(2 downto 0);
	
	SIGNAL MUX_EXE1_out: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL MUX_EXE2_out: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL MUX_EXE3_out: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL MUX_EXE4_out: STD_LOGIC_VECTOR(15 downto 0);
	
		  
BEGIN

	MUX_EXE1: MUX2to1_16bits PORT MAP (data_1, data_2, R1_R2_sel, MUX_EXE1_out);
	MUX_EXE2: MUX2to1_16bits PORT MAP (data_2,    IMM,  ALU_src , MUX_EXE2_out);
	
	MUX_EXE3: MUX3to1 PORT MAP (H_EXE_MEMO_data, MUX_EXE1_out, H_WB_data, FW_EXE3, MUX_EXE3_out );
	MUX_EXE4: MUX3to1 PORT MAP (H_EXE_MEMO_data, MUX_EXE2_out, H_WB_data, FW_EXE4, MUX_EXE4_out );
	
	ALUU     : ALU       PORT MAP (MUX_EXE3_out, MUX_EXE4_out, ALU_sel, ALU_res, ALU_Flags ); 
	
	CCRU     : CCR       PORT MAP (clk, async_Rest_For_CCR,unconditional_branching, ALU_Flags, flags_in_RTI, branch_Flags(0), branch_Flags(1), branch_Flags(2), ALU_F_enable, restore_WB, CCR_actual_out );
	CCR_res  <= CCR_actual_out;
	
	BU       : Branching PORT MAP (CCR_actual_out, control_Z, control_N, control_C, unconditional_branching, Branching_bool, branch_Flags );
	Branching_address <= MUX_EXE3_out;
	 

END A_EXE_STAGE;