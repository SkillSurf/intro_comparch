module MiniRiscV_withRam (
    input  logic        clk,
    input  logic        reset
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
        logic [3:0] rs2;   // used as immediate for ADDI/SUBI/LOAD/STORE
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

    //ALU Operations
    always_comb begin
        alu_in1 = regfile[instr.rs1];
        alu_in2 = regfile[instr.rs2];

        case(instr.opcode)
            4'b0000: alu_out = alu_in1 +  alu_in2;                                        // ADD
            4'b0001: alu_out = alu_in1 -  alu_in2;                                        // SUB
            4'b0010: alu_out = alu_in1 << alu_in2;                                       // SLL
            4'b0011: alu_out = alu_in1 >> alu_in2;                                       // SRL
            4'b0100: alu_out = alu_in1 *  alu_in2;                                       // MUL
            4'b0101: alu_out = (alu_in2 != 0) ? alu_in1 / alu_in2 : 16'hFFFF;            // DIV
            4'b0110: alu_out = alu_in1 + instr.rs2;                                      // ADDI
            4'b0111: alu_out = alu_in1 - instr.rs2;                                      // SUBI
            4'b1000: alu_out = dmem[instr.rs2];                                          // LOAD
            4'b1001: alu_out = alu_in1;                                                  // STORE (value to save)
            4'b1010: alu_out = alu_in1;                                                  // MOV
            default: alu_out = 0;
        endcase
    end

    // Sequential logic
    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            PC              <= 0;
            // register Initialization
            regfile[0]      <= 16'd0;   
            regfile[1]      <= 16'd5;   
            regfile[2]      <= 16'd0; 
            regfile[3]      <= 16'd0;  
            regfile[4]      <= 16'd0;    
            regfile[5]      <= 16'd7;  
            regfile[6]      <= 16'd0;  
            regfile[7]      <= 16'd0;   

            // Ram Initialization
            dmem[0] <= 16'd100;
            dmem[1] <= 16'd200;
            dmem[2] <= 16'd300;
            dmem[3] <= 16'd400;
            for (int i = 4; i < MEM_DEPTH; i++) begin
                dmem[i] <= 16'd0;
            end

        end else begin
            instr <= m_instr_mem[PC];
            case(instr.opcode)
                4'b1000: regfile[instr.rd] <= dmem[instr.rs2];                 // LOAD
                4'b1001: dmem[instr.rs2]   <= regfile[instr.rs1];              // STORE
                4'b1010: regfile[instr.rd] <= regfile[instr.rs1];              // MOV
                default: regfile[instr.rd] <= alu_out;                         // Normal ALU ops
            endcase
            PC <= PC + 1;
        end
    end

    // Program load
    initial begin
        // --- Program 1: Load and Store Example ---
        m_instr_mem[0] = '{4'b1000, 4'd3, 4'd0, 4'd1}; // LOAD  R3 = dmem[1] = 200
        m_instr_mem[1] = '{4'b1001, 4'd0, 4'd3, 4'd2}; // STORE dmem[2] = R3 = 200
        m_instr_mem[2] = '{4'b1010, 4'd4, 4'd3, 4'd0}; // MOV   R4 = R3

        // --- Program 2: Simple Arithmetic ---
        m_instr_mem[3] = '{4'b0110, 4'd5, 4'd1, 4'd3}; // ADDI R5=R1+3 (5+3=8)
        m_instr_mem[4] = '{4'b0100, 4'd6, 4'd5, 4'd1}; // MUL  R6=R5*R1 (8*5=40)

        // Fill rest with NOPs
        for (int i = 5; i < MEM_DEPTH; i++) begin
            m_instr_mem[i] = '{4'b1111,4'd0,4'd0,4'd0}; // NOP
        end
    end

endmodule
