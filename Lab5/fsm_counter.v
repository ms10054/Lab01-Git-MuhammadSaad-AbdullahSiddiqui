`timescale 1ns / 1ps
module top_system (
input wire clk,
input wire rst,
input wire [15:0] sw_pins,
output wire [15:0] led_pins,
output wire [3:0] countdown_display,
output wire [6:0] seg,
output wire [3:0] an
);
wire [31:0] bus_data;
wire [15:0] fsm_led_value;
wire [3:0] current_count;
wire [3:0] display_digit; // state-aware digit for 7-seg
assign countdown_display = current_count;
assign an = 4'b1110;
// Switch reader
switches switch_reader (
.clk (clk),
.rst (rst),
.btns (16'b0),
.switches (sw_pins),
.readEnable (1'b1),
.readData (bus_data),
.writeData (32'b0),
.writeEnable (1'b0),
.memAddress (30'b0)
);
// Main FSM + countdown logic
fsm_control main_fsm (
.clk (clk),
.rst (rst),
.switch_values (bus_data[15:0]),
.led_pattern (fsm_led_value),
.count_value (current_count),
.display_digit (display_digit) // NEW: use this for 7-seg
);
// 7-seg now driven by display_digit, not current_count
seg7_decoder display_decoder (
.digit (display_digit),
.seg (seg)
);
// LED driver
led_driver led_controller (
.clk (clk),
.rst (rst),
.writeData ({16'b0, fsm_led_value}),
.writeEnable (1'b1),
.readEnable (1'b0),
.memAddress (30'b0),
.readData (),
.leds (led_pins)
);
endmodule