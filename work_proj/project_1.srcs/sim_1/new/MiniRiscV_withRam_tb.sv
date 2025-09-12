module tb_MiniRiscV;
    logic clk;
    logic reset;

    // Instantiate DUT
    MiniRiscV_withRam dut (.clk(clk), .reset(reset));

    // Clock gen
    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #10 reset = 0;

        // Run for some cycles
        #200;

        // Dump register values
        $display("R1 = %0d", dut.regfile[1]);
        $display("R3 = %0d", dut.regfile[3]);
        $display("R4 = %0d", dut.regfile[4]);
        $display("R5 = %0d", dut.regfile[5]);
        $display("R6 = %0d", dut.regfile[6]);
        
        // Dump memory values
        $display("DMEM[2] = %0d", dut.dmem[2]);

        $finish;
    end
endmodule
