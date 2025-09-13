`timescale 1ns/1ps

module tb_state_machine;
    logic clk, rst_n, start;
    logic signed [15:0] x_in;
    logic signed [31:0] y_out;
    logic done;

    // Instantiate DUT
    state_machine dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .x_in(x_in),
        .y_out(y_out),
        .done(done)
    );

    // Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 0; start = 0; x_in = 0;
        #20 rst_n = 1;
        // Test 01
        @(posedge clk);
        x_in = 10; 
        start = 1;
        @(posedge clk);
        start = 0;

        wait(done);
        $display("x=%0d, y=%0d (Expected=38)", x_in, y_out);
        
        @(posedge clk);

        // Test 02
        @(posedge clk);
        x_in = -4;
        start = 1;
        @(posedge clk);
        start = 0;

        wait(done);
        $display("x=%0d, y=%0d (Expected=-4)", x_in, y_out);

        #20 $finish;
    end

endmodule
