`timescale 1ns / 1ps

module TopLevelProcessor_tb;

    reg clk;
    reg rst;
    reg btn_rst;
    reg [15:0] sw;

    wire [31:0] output_value;
    wire bne_detected;
    wire bne_taken;

    TopLevelProcessor processor_inst (
        .clk         (clk),
        .rst         (rst),
        .btn_rst     (btn_rst),
        .sw          (sw),
        .output_value(output_value),
        .bne_detected(bne_detected),
        .bne_taken   (bne_taken)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        btn_rst = 0;
        sw = 16'b0;

        // 3! = 6
        // expected output_value = 0x00010006
        sw = 16'b0000_0000_0000_0011;

        rst = 1;
        #500;
        rst = 0;

        #200000;


        #1000;


        // 4! = 24
        // expected output_value = 0x00010018
        sw = 16'b0000_0000_0000_0100;

        rst = 1;
        #500;
        rst = 0;

        #300000;


        #1000;

        // 5! = 120
        // expected output_value = 0x00010078
        sw = 16'b0000_0000_0000_0101;

        rst = 1;
        #500;
        rst = 0;

        #500000;

        #1000;

        $finish;
    end

endmodule