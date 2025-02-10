import re

def asm_to_mem(asm_file, mem_file):
    # Initialize 4096 lines, each with 16 bits (default empty: '0' * 16)
    total_lines = 4096
    output_lines = ['0' * 16] * total_lines  # Default all lines to "0000000000000000"
    
    # Instruction and register mappings
    opcodes = {
        'NOP': '00000', 'HLT': '00001', 'SETC': '00010', 'NOT': '00011',
        'INC': '00100', 'OUT': '00101', 'IN': '00110', 'MOV': '00111',
        'ADD': '01000', 'SUB': '01001', 'AND': '01010', 'IADD': '01011',
        'PUSH': '01100', 'POP': '01101', 'LDM': '01110', 'LDD': '01111',
        'STD': '10000', 'JZ': '10001', 'JN': '10010', 'JC': '10011',
        'JMP': '10100', 'CALL': '10101', 'RET': '10110', 'INT': '10111',
        'RTI': '11000'
    }

    # 8 Registers are represented as 3-bit binary numbers
    registers = { 
        f'R{i}': f'{i:03b}' for i in range(8)
    }

    with open(asm_file, 'r') as asm, open(mem_file, 'w') as mem:
        lines_written = 0  # Counter to keep track of how many lines we have written
        current_address = 0  # Start at address 0

        #not line: Skips the iteration if the line is empty
        for line in asm:
            
            line = line.strip()
            
            # Remove whitespace and ignore comments
            #[0]The part before '#' the (keep). [1]The part after '#' (discard).
            line = line.split('#', 1)[0].strip() 
            if not line:  # Skip empty lines
                continue
            
            # Check for .ORG directive
            if line.startswith('.ORG'):
                parts = line.split()
                if len(parts) < 2:
                    raise ValueError(f"Invalid .ORG directive: {line}")
                address = int(parts[1], 16)  # hexadecimal string -> integer
                # Set current address or handle as needed
                current_address = address
                if current_address >= total_lines:
                    raise ValueError(f".ORG address out of range: {current_address}")
                continue
                

            if re.match(r'^[0-9A-Fa-f]+$', line):  # Check if the line is a standalone number
                number = int(line, 16)             # Treat the number as hexadecimal     
                output_lines[current_address] = f"{number:016b}" # Write it as a 16-bit binary number
                current_address += 1  
                continue

            parts = re.split(r'[ ,()]+', line)
            instr = parts[0]

            if instr not in opcodes:
                raise ValueError(f"Unknown instruction: {instr}")

            opcode = opcodes[instr]
            binary_instr = opcode
            rsrc1 = rsrc2 = '000'
            rdst = '111'
            index_bit = imm_bit = '0'
            
            #needs opcode only 
            if instr == 'NOP' or instr == 'HLT' or instr == 'SETC' or instr == 'RET' or instr == 'RTI':
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                output_lines[current_address] = binary_instr
                current_address += 1
                continue

            #needs opcode + bit index
            elif instr == 'INT':
                index_bit = parts[1]
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                output_lines[current_address] = binary_instr
                current_address += 1
                continue
            
            #needs opcode + Rsrc1
            elif instr in ['OUT' , 'PUSH','JZ', 'JN', 'JC', 'JMP', 'CALL']:
                rsrc1 = registers.get(parts[1], '000')
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                output_lines[current_address] = binary_instr
                current_address += 1
                continue

            #needs opcode + Rdst
            elif instr in ['IN', 'POP']:
                rdst = registers.get(parts[1], '000')
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                output_lines[current_address] = binary_instr
                current_address += 1
                continue

            #needs opcode + Rdst + Rsrc1
            elif instr in ['MOV', 'NOT', 'INC']:
                rdst = registers.get(parts[1], '000')
                rsrc1 = registers.get(parts[2], '000')
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                output_lines[current_address] = binary_instr
                current_address += 1
                continue
            
            #needs opcode + Rdst + Rsrc1 + Rsrc2
            elif instr in ['ADD', 'SUB', 'AND']:
                rdst = registers.get(parts[1], '000')
                rsrc1 = registers.get(parts[2], '000')
                rsrc2 = registers.get(parts[3], '000')
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                output_lines[current_address] = binary_instr
                current_address += 1
                continue
            
            #needs opcode + Rdst + Rsrc1 + IMM
            elif instr == 'IADD':
                rdst = registers.get(parts[1], '000')
                rsrc1 = registers.get(parts[2], '000')
                imm_bit = '1'
                imm_value = int(parts[3], 16)
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                output_lines[current_address] = binary_instr
                current_address += 1
                output_lines[current_address] = f"{imm_value:016b}"
                current_address += 1
                continue

            #needs opcode + Rdst + IMM
            elif instr == 'LDM':
                rdst = registers.get(parts[1], '000')
                imm_bit = '1'
                imm_value = int(parts[2], 16)
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                output_lines[current_address] = binary_instr
                current_address += 1
                output_lines[current_address] = f"{imm_value:016b}"
                current_address += 1
                continue
            
            #LDD Rdst, offset(Rsrc1) 
            #STD Rsrc1, offset(Rsrc2) 
            elif instr in ['LDD', 'STD']:
                if instr == 'LDD':
                    rdst = registers.get(parts[1], '000')
                    rsrc1 = registers.get(parts[3], '000')
                else:
                    rsrc1 = registers.get(parts[1], '000')
                    rsrc2 = registers.get(parts[3], '000')
                    
                imm_bit = '1'
                offset = int(parts[2], 16)
                binary_instr += rsrc1 + rsrc2 + rdst + index_bit + imm_bit
                output_lines[current_address] = binary_instr
                current_address += 1
                output_lines[current_address] = f"{offset:016b}"
                current_address += 1
                continue

            else:
                raise ValueError(f"Instruction not yet supported: {instr}")
               
        # Write all 4096 lines to the memory file
        mem.write('\n'.join(output_lines) + '\n')
        

# Example usage:
# asm_to_mem('asm_example.asm', 'project.mem')
asm_to_mem('testcase2.txt', 'testcase22.mem')
