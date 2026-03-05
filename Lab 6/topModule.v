`timescale 1ns / 1ps

module topModule (
    input        clk,
    input        rst,
    input  [3:0] sw,
    input  [3:0] btns,
    output [15:0] leds
);

    // ---------- Hardcoded ALU operands ----------
    wire [31:0] A = 32'h10101010;
    wire [31:0] B = 32'h01010101;

    // ---------- Debouncer ----------
    wire reset_debounced;
    debouncer debouncer_inst (
        .clk  (clk),
        .pbin (btns[0]),
        .pbout(reset_debounced)
    );
    wire system_reset = rst | reset_debounced;

    // ---------- FSM ----------
    wire [3:0] display_leds;
    wire [3:0] alu_control;
    wire       cnt_en;
    fsm fsm_inst (
        .clk        (clk),
        .rst        (system_reset),
        .sw_in      (sw),
        .led_out    (display_leds),
        .alu_control(alu_control),
        .cnt_en     (cnt_en)
    );

    // ---------- ALU_32Bit ----------
    wire        carry_flag;
    wire        zero_flag;
    wire [31:0] alu_result;
    ALU_32Bit alu_inst (
        .A          (A),
        .B          (B),
        .Control    (alu_control),
        .signal_out (carry_flag),
        .Result     (alu_result),
        .Zero       (zero_flag)
    );

    // ---------- led ----------
    wire [31:0] led_out;
    led led_inst (
        .clk    (clk),
        .rst    (system_reset),
        .dataIn (alu_result),
        .dataOut(led_out)
    );

    // ---------- switches ----------
    wire [31:0] sw_readData;
    switches switches_inst (
        .clk        (clk),
        .rst        (system_reset),
        .writeData  (32'd0),
        .writeEnable(1'b0),
        .readEnable (1'b1),
        .memAddress (30'd0),
        .readData   (sw_readData),
        .leds       ()
    );

    // ---------- Output ----------
    assign leds = led_out[15:0];

endmodule