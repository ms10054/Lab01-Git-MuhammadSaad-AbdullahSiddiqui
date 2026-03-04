`timescale 1ns / 1ps

module led (
    input         clk,
    input         rst,
    input  [15:0] btns,
    input  [31:0] writeData,
    input         writeEnable,
    input         readEnable,
    input  [29:0] memAddress,
    input  [15:0] sw,
    output reg [31:0] readData
);
    wire reset_debounced;
    debouncer debouncer (
        .clk  (clk),
        .pbin (btns[0]),
        .pbout(reset_debounced)
    );
    wire system_reset = rst | reset_debounced;
    wire [3:0]  display_leds;
    wire [3:0]  alu_control;
    wire        counter_enable;
    fsm fsm_counter (
        .clk        (clk),
        .rst        (system_reset),
        .sw_in      (sw[3:0]),
        .led_out    (display_leds),
        .alu_control(alu_control),
        .cnt_en     (counter_enable)
    );
    wire [31:0] A = 32'h10101010;
    wire [31:0] B = 32'h01010101;
    wire        carry_flag;
    wire [31:0] computation_result;
    ALU_32Bit alu (
        .A          (operand_A),
        .B          (operand_B),
        .Control    (alu_control),
        .signal_out (carry_flag),
        .Y          (computation_result)
    );
    always @(posedge clk or posedge system_reset) begin
        if (system_reset)
            readData <= 32'd0;
        else if (readEnable)
            readData <= computation_result;
    end
endmodule