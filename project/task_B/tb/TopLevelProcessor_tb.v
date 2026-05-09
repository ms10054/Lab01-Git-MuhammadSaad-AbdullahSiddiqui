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

    // 100 MHz clock = 10 ns period
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        btn_rst = 0;
        sw = 16'b0;

        // Reset processor
        rst = 1;
        #500;
        rst = 0;

        // Wait for full Task B program
        #1000000;

        $display("Final output_value = %h", output_value);
        $display("BNE detected       = %b", bne_detected);
        $display("BNE taken          = %b", bne_taken);

        $finish;
    end

endmodule