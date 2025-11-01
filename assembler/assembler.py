# MiniRiscV Assembler - Register-Only Version

# Instruction encoding
OPCODES = {
    'add': 0, 'sub': 1, 'sll': 2, 'srl': 3, 'mul': 4, 'div': 5,
    'load': 8, 'store': 9, 'mov': 10
}

def assembler(line):
    """Convert assembly line to 16-bit machine code"""
    if not line or line.startswith('#'): 
        return None
    
    parts = line.replace(',', ' ').split()
    op, operands = parts[0], parts[1:]
    
    # All operands are registers
    rd = int(operands[0].replace('r', ''))
    rs1 = int(operands[1].replace('r', ''))
    
    # For 3-operand instructions, get rs2
    if len(operands) == 3:
        rs2 = int(operands[2].replace('r', ''))
    else:
        rs2 = 0  # For 2-operand instructions
    
    # Pack into 16-bit: [opcode:4][rd:4][rs1:4][rs2:4]
    return (OPCODES[op] << 12) | (rd << 8) | (rs1 << 4) | rs2

# Example usage
program = [
    "add r5 r1 r2",     # r5 = r1 + r2
    "sub r3 r5 r4",     # r3 = r5 - r4
    "mul r4 r2 r3",     # r4 = r2 * r3
    "load r7 r2 r0",    # r7 = memory[r2 + r0]
    "store r5 r1 r0",   # memory[r1 + r0] = r5
    "mov r0 r3",        # r0 = r3
]

print("Machine Code:")
for line in program:
    code = assembler(line)
    if code:
        print(f"16'b{code & 0xffff:016b}  // {line}")
