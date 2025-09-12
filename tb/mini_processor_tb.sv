`timescale 1ns/1ps

module MiniRiscV_tb;

    reg clk;
    reg reset;

    // Instantiate DUT
    MiniRiscV uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset sequence
    initial begin
        reset = 1;
        #20;
        reset = 0;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | PC=%0d | R1=%0d | R2=%0d | R3=%0d | R4=%0d | R5=%0d | R6=%0d | R7=%0d",
                  $time, uut.PC,
                  uut.regfile[1], uut.regfile[2], uut.regfile[3], uut.regfile[4],
                  uut.regfile[5], uut.regfile[6], uut.regfile[7]);
        #300;
        $display("==== Simulation Complete ====");
        $stop;
    end

endmodule
