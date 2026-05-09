`timescale 1ns / 1ps

module topModule (
    input  wire        clk,
    input  wire        rst,
    input  wire        btn_rst,
    input  wire [15:0] sw,
    output wire [15:0] leds,
    output wire [6:0]  seg,
    output wire [3:0]  an
);

    wire [31:0] output_value;

    TopLevelProcessor processor_inst (
        .clk         (clk),
        .rst         (rst),
        .btn_rst     (btn_rst),
        .sw          (sw),
        .output_value(output_value),
        .bne_detected(),
        .bne_taken()
    );

    // Lower 16 bits on LEDs
    assign leds = output_value[15:0];

    // Upper 16 bits on seven-segment
    sevensegment sevenseg_inst (
        .clk (clk),
        .data(output_value[31:16]),
        .seg (seg),
        .an  (an)
    );

endmodule