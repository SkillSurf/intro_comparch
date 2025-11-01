`timescale 1ns/1ps

module MiniRiscV_tb;
    parameter REG_COUNT = 8;
    parameter REG_WIDTH = 16;
    parameter MEM_DEPTH = 16;

    reg clk;
    reg reset;

    // Instantiate DUT
    MiniRiscV #(.REG_COUNT(REG_COUNT), .REG_WIDTH(REG_WIDTH), .MEM_DEPTH(MEM_DEPTH)) uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    task memory_init();
        begin
            // FSM equation calculation  
            uut.regfile[0] <= 16'd0;  
            uut.regfile[1] <= 16'd10;   
            uut.regfile[2] <= 16'd5;   
            uut.regfile[3] <= 16'd3;
            uut.regfile[4] <= 16'd7;
            for (int j = 5; j < REG_COUNT; j++)
                uut.regfile[j] <= 16'd0;
                
            // --- Program: FSM equation ---   
            uut.m_instr_mem[0] = '{4'b0000, 4'd5, 4'd1, 4'd2}; // ADD  R5 = R1 + R2
            uut.m_instr_mem[1] = '{4'b0100, 4'd5, 4'd5, 4'd3}; // MUL  R5 = R5 * R3
            uut.m_instr_mem[2] = '{4'b0001, 4'd5, 4'd5, 4'd4}; // SUB  R5 = R5 - R4

            // Simple LOAD/STORE test
            uut.dmem[0] = 16'd100;            
            uut.dmem[1] = 16'd200;
            uut.dmem[2] = 16'd300;
            // --- Program: Load/Store/MOV ---
            uut.m_instr_mem[3] = '{4'b1000, 4'd6, 4'd0, 4'd1}; // LOAD  R6 = dmem[0+1] = 200
            uut.m_instr_mem[4] = '{4'b1001, 4'd6, 4'd0, 4'd2}; // STORE dmem[0+2] = R6 = 200
            uut.m_instr_mem[5] = '{4'b1010, 4'd7, 4'd6, 4'd0}; // MOV   R4 = R3
            
            // Fill rest with NOPs
            for (int i = 6; i < MEM_DEPTH; i++)
                uut.m_instr_mem[i] = '{4'b1111,4'd0,4'd0,4'd0}; 
        end
    endtask
    

    // Reset sequence
    initial begin
        reset = 1;
        memory_init();
        repeat (2) @(negedge clk);
        reset = 0;
        repeat (15) @(posedge clk);
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | PC=%0d | R0=%0d | R1=%0d | R2=%0d | R3=%0d | R4=%0d | R5=%0d | R6=%0d | R7=%0d",
                  $time, uut.PC,
                  uut.regfile[0], uut.regfile[1], uut.regfile[2], uut.regfile[3], uut.regfile[4],
                  uut.regfile[5], uut.regfile[6], uut.regfile[7]);
        #300;
        $display("==== Simulation Complete ====");
        $stop;
    end

endmodule
