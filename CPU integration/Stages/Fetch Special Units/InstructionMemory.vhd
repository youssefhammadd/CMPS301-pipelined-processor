library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL; -- Add this for text file operations on STD_LOGIC_VECTOR
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

ENTITY InstructionMemory IS
    GENERIC(
        addressWidth : INTEGER := 12;
        wordWidth    : INTEGER := 16
    );
    PORT(
        InstructionMemory_address_in_Bus : IN  STD_LOGIC_VECTOR((addressWidth-1 ) DOWNTO 0);
        InstructionMemory_Imm_Bit        : OUT STD_LOGIC;
        InstructionMemory_Instruction_Bus,
        InstructionMemory_Imm_Bus        : OUT STD_LOGIC_VECTOR((wordWidth - 1) DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE InstructionMemory_Arch OF InstructionMemory IS
    TYPE memoryType IS ARRAY((2 ** addressWidth) - 1 DOWNTO 0) OF 
        STD_LOGIC_VECTOR(wordWidth - 1 DOWNTO 0);

    IMPURE FUNCTION load_memory(load_file_name : IN STRING) RETURN memoryType IS
        FILE ram_file : TEXT OPEN READ_MODE IS load_file_name;
        VARIABLE read_line : LINE;
        VARIABLE ram_contents : memoryType;
        VARIABLE bit_data : STD_LOGIC_VECTOR(wordWidth - 1 DOWNTO 0); -- STD_LOGIC_VECTOR to store data
    BEGIN
    
        FOR i IN ram_contents'RANGE LOOP
            READLINE(ram_file, read_line); -- Read a line from the file
            READ(read_line, bit_data);     -- Read as STD_LOGIC_VECTOR
            ram_contents( ((2 ** addressWidth) - 1) - i) := bit_data;  -- Store the data in memory
        END LOOP;
        
        RETURN ram_contents;
    END FUNCTION;

    SIGNAL ram_memory : memoryType := load_memory("C:/memoryFiles/testcase22.mem");
	
    SIGNAL Out_instruction : STD_LOGIC_VECTOR(wordWidth - 1 DOWNTO 0);
	SIGNAL Checker_on_input_address : STD_LOGIC;
	SIGNAL valid_address : BOOLEAN;

BEGIN


	valid_address <= (to_integer(unsigned(InstructionMemory_address_in_Bus)) < 2 ** addressWidth);


	Checker_on_input_address <=
    '1' WHEN (to_integer(unsigned(InstructionMemory_address_in_Bus)) >= 2 ** addressWidth) ELSE
    '0';
	
    Out_instruction <= ram_memory(to_integer(unsigned(InstructionMemory_address_in_Bus)))
    WHEN valid_address
    ELSE (OTHERS => '0');
    InstructionMemory_Instruction_Bus <= Out_instruction;
    InstructionMemory_Imm_Bit <= Out_instruction(0);
	
	
    InstructionMemory_Imm_Bus <= 
    ram_memory(to_integer(unsigned(InstructionMemory_address_in_Bus)) + 1) WHEN 
        (Checker_on_input_address = '0' AND valid_address AND 
         (to_integer(unsigned(InstructionMemory_address_in_Bus)) + 1 < 2 ** addressWidth)) ELSE
    (OTHERS => '0');
END ARCHITECTURE;
