library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY decode_cycle IS 
GENERIC( 
	width : integer := 16 ); 
PORT( 
	--inputs
	clk,rst 		: in std_logic; 
	instruction, pc, Write_Data_inRegFile : in std_logic_vector(WIDTH-1 downto 0);
	Rdst_inRegFile : in std_logic_vector(2 DOWNTO 0);
	RegWrite_from_WB : in std_logic;
	Flush_controlUnit : IN std_logic;
	--control
	Flag_Enable : OUT STD_LOGIC;
	OutPort_Enable : OUT STD_LOGIC;
	RegWrite : OUT STD_LOGIC;
	Address: OUT STD_LOGIC;
	INT_sig: OUT STD_LOGIC;
	MemRead : OUT STD_LOGIC;
	MemWrite : OUT STD_LOGIC;
	MTR : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
	SP_sig : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- SP[1] = PLUS; SP[0] = MINUS
	FR: OUT STD_LOGIC;
	Write_Data_sel : OUT STD_LOGIC;
	RET_sig: OUT STD_LOGIC;
	JZ: OUT STD_LOGIC;
	JN: OUT STD_LOGIC;
	JC: OUT STD_LOGIC;
	ALU_sel : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
	JMP_branch : OUT STD_LOGIC;
	UC: OUT STD_LOGIC;
	RdRs_sel: OUT STD_LOGIC;
	Rsrc1_Rscr2_sel : OUT STD_LOGIC;
	PC_disable: OUT STD_LOGIC;
	--regfile
	read_data1, read_data2 : out std_logic_vector(WIDTH-1 downto 0);
	--pcadder
	pc_increment : OUT std_logic_vector(WIDTH-1 DOWNTO 0)
	);
END ENTITY;
	

ARCHITECTURE decode_cycle_arch of decode_cycle IS 
	
	COMPONENT Control_Unit IS
		PORT (
		rst : IN STD_LOGIC;
		opcode : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		Flag_Enable : OUT STD_LOGIC;
		OutPort_Enable : OUT STD_LOGIC;
		RegWrite : OUT STD_LOGIC;
		Address: OUT STD_LOGIC;
		INT_sig: OUT STD_LOGIC;
		MemRead : OUT STD_LOGIC;
		MemWrite : OUT STD_LOGIC;
		MTR : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		SP_sig : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- SP[1] = PLUS; SP[0] = MINUS
		FR: OUT STD_LOGIC;
		Write_Data_sel : OUT STD_LOGIC;
		RET_sig: OUT STD_LOGIC;
		JZ: OUT STD_LOGIC;
		JN: OUT STD_LOGIC;
		JC: OUT STD_LOGIC;
		ALU_sel : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		JMP_branch : OUT STD_LOGIC;
		UC: OUT STD_LOGIC;
		RdRs_sel: OUT STD_LOGIC;
		Rsrc1_Rscr2_sel : OUT STD_LOGIC;
		PC_disable: OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT Reg_File IS 
	GENERIC( 
		address_bits : integer := 3 ; 
		data_bits : integer := 16 ); 
	PORT( 
		clk,rst,we 		: in std_logic; 
		Rsrc1,Rsrc2 : in std_logic_vector(address_bits-1 downto 0); 
		Rdst : in std_logic_vector(address_bits-1 downto 0);
		write_data : in std_logic_vector(data_bits-1 downto 0);
		read_data1, read_data2 : out std_logic_vector(data_bits-1 downto 0)
		);
	END COMPONENT;	
	
	COMPONENT pc_one_adder IS
	generic (
		WIDTH : integer := 16
	);
	PORT(
		pc_in : IN std_logic_vector(WIDTH-1 DOWNTO 0);
		pc_increment : OUT std_logic_vector(WIDTH-1 DOWNTO 0)
    );
	END COMPONENT;
	
	signal Flush_control_unit_or_Reset : std_logic := '0';
	
BEGIN 
	Flush_control_unit : ENTITY work.OR_2_inputs
	PORT MAP(
        A => rst,
        B => Flush_controlUnit,
        Y => Flush_control_unit_or_Reset
    );
	CU : Control_Unit PORT MAP(Flush_control_unit_or_Reset, instruction(15 downto 11), Flag_Enable, OutPort_Enable, RegWrite, Address, INT_sig, MemRead, MemWrite, MTR, SP_sig, FR, Write_Data_sel, RET_sig, JZ, JN, JC, ALU_sel, JMP_branch, UC, RdRs_sel, Rsrc1_Rscr2_sel, PC_disable);
	
	RF : Reg_File PORT MAP(clk, rst, RegWrite_from_WB, instruction(10 downto 8), instruction(7 downto 5), Rdst_inRegFile, Write_Data_inRegFile, read_data1, read_data2);
	PC_inc : pc_one_adder PORT MAP(pc, pc_increment);

END ARCHITECTURE;



