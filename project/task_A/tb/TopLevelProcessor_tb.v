`timescale 1ns / 1ps

module TopLevelProcessor_tb;

    reg clk;
    reg rst;
    reg btn_rst;
    reg [15:0] sw;

    wire [31:0] output_value;

    TopLevelProcessor processor_inst (
        .clk(clk),
        .rst(rst),
        .btn_rst(btn_rst),
        .sw(sw),
        .output_value(output_value)
    );

    // 100 MHz clock = 10 ns period
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        btn_rst = 0;
        sw = 16'b0;

        // =====================================================
        // TEST CASE 1: countdown from 7
        // Expected output_value:
        // 7 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1 -> 0
        // =====================================================
        sw = 16'b0000_0000_0000_0111; // 7
        rst = 1;
        #100;
        rst = 0;

        #8000;

        // =====================================================
        // TEST CASE 2: countdown from 4
        // Expected output_value:
        // 4 -> 3 -> 2 -> 1 -> 0
        // =====================================================
        sw = 16'b0000_0000_0000_0100; // 4
        rst = 1;
        #100;
        rst = 0;

        #6000;

        // =====================================================
        // TEST CASE 3: countdown from 2
        // Expected output_value:
        // 2 -> 1 -> 0
        // =====================================================
        sw = 16'b0000_0000_0000_0010; // 2
        rst = 1;
        #100;
        rst = 0;

        #4000;

        $finish;
    end

endmodule