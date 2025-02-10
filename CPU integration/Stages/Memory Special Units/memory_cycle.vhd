library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY memory_cycle IS 
GENERIC( 
	width : integer := 16 ); 
PORT( 
	--inputs
	clk,Rst 		: in std_logic; 
	Alu_res, pc_inc_withf, pc_inc_withoutf, Data1 : in std_logic_vector(WIDTH-1 downto 0);
	SP_old : IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
	--control
	INT_sig: IN STD_LOGIC;
	MemRead : IN STD_LOGIC;
	MemWrite : IN STD_LOGIC;
	SP_sig : IN STD_LOGIC_VECTOR (1 DOWNTO 0); -- SP[1] = PLUS; SP[0] = MINUS
	Write_Data_sel : IN STD_LOGIC;
	--sp_adder_unit
	SP_new : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
	Address_enters_the_DM : OUT STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0);
	--datamemory
	memory_out : out std_logic_vector(WIDTH-1 downto 0)
	);
END ENTITY;
	

ARCHITECTURE memory_cycle_arch of memory_cycle IS 
	
	COMPONENT Data_Memory is
    generic (
        WIDTH : integer := 16
    );
    port (
        clk, rst, re, we : in std_logic;
        address, write_data : in std_logic_vector(WIDTH-1 downto 0);
        memory_out : out std_logic_vector(WIDTH-1 downto 0)
    );
	end COMPONENT;
	
	
	COMPONENT SP_adder_unit is
    generic (
        WIDTH : integer := 16
    );
    port (
		  Rst : in std_logic;
        SP_old : in  std_logic_vector(WIDTH-1 downto 0);  -- Input value
        SP_sel : in  std_logic_vector(1 downto 0);         -- Selection signal
        SP_new : out std_logic_vector(WIDTH-1 downto 0)     -- Output value
    );
	end COMPONENT;
	
	COMPONENT MUX_2to1 IS
	GENERIC (
		WIDTH : integer := 16
	);
    PORT (
		  Sel     : IN  STD_LOGIC;   -- Selector
        A, B    : IN std_logic_vector(WIDTH-1 DOWNTO 0);   -- Inputs
        Y       : OUT std_logic_vector(WIDTH-1 DOWNTO 0)    -- Output
    );
	END COMPONENT;
	
	
	COMPONENT MUX3to1_16bits is
    Port (
        A : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 1
        B : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 2
        C : in STD_LOGIC_VECTOR(15 downto 0);        -- Input 3
        SEL : in STD_LOGIC_VECTOR(1 downto 0); -- 2-bit Select signal
        Y : out STD_LOGIC_VECTOR(15 downto 0)        -- Output
    );
	END COMPONENT;
	
	signal INT_Call_MUX_out : std_logic_vector(width-1 downto 0);
	signal Write_Data_MUX_out_Mem_In : std_logic_vector(width-1 downto 0);
	signal Address_MUX_out_Mem_In : std_logic_vector(width-1 downto 0);
	signal SP_new_internal : std_logic_vector(width-1 DOWNTO 0);

	
BEGIN 
	Address_enters_the_DM <= Address_MUX_out_Mem_In;
	SP_new <= SP_new_internal;
	INT_MUX: MUX_2to1 PORT MAP(INT_sig, pc_inc_withoutf, pc_inc_withf, INT_Call_MUX_out);
	WRITEDATA_MUX: MUX_2to1 PORT MAP(Write_Data_sel, Data1 ,INT_Call_MUX_out, Write_Data_MUX_out_Mem_In);
	DM: Data_Memory PORT MAP(clk, Rst, MemRead, MemWrite, Address_MUX_out_Mem_In, Write_Data_MUX_out_Mem_In, memory_out);
	SP_MUX: MUX3to1_16bits PORT MAP(Alu_res, SP_old, SP_new_internal, SP_sig, Address_MUX_out_Mem_In);
	SP : SP_adder_unit PORT MAP (Rst, SP_old, SP_sig, SP_new_internal);
	
END ARCHITECTURE;


