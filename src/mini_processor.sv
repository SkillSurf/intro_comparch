module MiniRiscV (
    input  logic clk,
    input  logic reset
);

    // Parameters
    parameter REG_COUNT = 8;
    parameter REG_WIDTH = 16;
    parameter MEM_DEPTH = 16;

    // Program Counter
    logic [3:0] PC;

    // Instruction format
    typedef struct packed {
        logic [3:0] opcode;
        logic [3:0] rd;
        logic [3:0] rs1;
        logic [3:0] rs2;   // immediate / offset
    } instr_t;

    // Instruction Memory
    instr_t m_instr_mem [0:MEM_DEPTH-1];

    // Register File
    logic [REG_WIDTH-1:0] regfile [0:REG_COUNT-1];

    // Data Memory (RAM)
    logic [REG_WIDTH-1:0] dmem [0:MEM_DEPTH-1];

    // Current instruction
    instr_t instr;

    // ALU
    logic [REG_WIDTH-1:0] alu_in1, alu_in2, alu_out;

    // Intermediate address for RAM access
    logic [3:0] addr;

    // ALU Operations
    always_comb begin
        alu_in1 = regfile[instr.rs1];
        alu_in2 = regfile[instr.rs2];

        case(instr.opcode)
            4'b0000: alu_out = alu_in1 +  alu_in2;       // ADD
            4'b0001: alu_out = alu_in1 -  alu_in2;       // SUB
            4'b0010: alu_out = alu_in1 << alu_in2;       // SLL
            4'b0011: alu_out = alu_in1 >> alu_in2;       // SRL
            4'b0100: alu_out = alu_in1 *  alu_in2;       // MUL
            4'b0101: alu_out = (alu_in2 != 0) ? alu_in1 / alu_in2 : 16'hFFFF; // DIV
            4'b0110: alu_out = alu_in1 + instr.rs2;     // ADDI
            4'b0111: alu_out = alu_in1 - instr.rs2;     // SUBI
            4'b1010: alu_out = alu_in1;                 // MOV
            default: alu_out = 0;
        endcase
    end

    // Sequential logic
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            PC <= 0;
            // init registers
            regfile[0] <= 16'd0;   
            regfile[1] <= 16'd5;   
            regfile[2] <= 16'd0;   
            regfile[5] <= 16'd7;   

            // init RAM
            for (int j = 0; j < MEM_DEPTH; j++) dmem[j] <= 16'd0;

            instr <= '{default:0};
        end else begin
            instr <= m_instr_mem[PC];

            addr = regfile[instr.rs1] + instr.rs2;

            case(instr.opcode)
                4'b1000: regfile[instr.rd] <= dmem[addr];    // LOAD
                4'b1001: dmem[addr] <= regfile[instr.rs2];   // STORE
                4'b1010: regfile[instr.rd] <= alu_out;       // MOV
                default: regfile[instr.rd] <= alu_out;       // ALU ops
            endcase

            PC <= PC + 1;
        end
    end

    // Program load
    initial begin
        // Simple LOAD/STORE test
        dmem[0] = 16'd100;
        dmem[1] = 16'd200;
        dmem[2] = 16'd300;

        // --- Program: Load/Store/MOV ---
        m_instr_mem[0] = '{4'b1000, 4'd3, 4'd0, 4'd1}; // LOAD  R3 = dmem[0+1] = 200
        m_instr_mem[1] = '{4'b1001, 4'd0, 4'd3, 4'd2}; // STORE dmem[0+2] = R3 = 200
        m_instr_mem[2] = '{4'b1010, 4'd4, 4'd3, 4'd0}; // MOV   R4 = R3

        // Fill rest with NOPs
        for (int i = 3; i < MEM_DEPTH; i++)
            m_instr_mem[i] = '{4'b1111,4'd0,4'd0,4'd0};
    end

endmodule
