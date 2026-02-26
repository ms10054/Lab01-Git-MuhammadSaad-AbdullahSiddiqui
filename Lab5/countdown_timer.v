`timescale 1ns / 1ps
module countdown_timer (
input wire clk,
input wire rst,
input wire load, // pulse: latch switch value and reset divider
input wire active, // high while counting down
input wire [15:0] sw_in,
output reg [3:0] count
);
reg [26:0] clk_div; // 27 bits handles up to 134M cycles (~1.34s at 100MHz)
// Priority encode highest ON switch bit
function [3:0] encode_sw;
input [15:0] sw;
begin
if (sw[15]) encode_sw = 4'd15;
else if (sw[14]) encode_sw = 4'd14;
else if (sw[13]) encode_sw = 4'd13;
else if (sw[12]) encode_sw = 4'd12;
else if (sw[11]) encode_sw = 4'd11;
else if (sw[10]) encode_sw = 4'd10;
else if (sw[9]) encode_sw = 4'd9;
else if (sw[8]) encode_sw = 4'd8;
else if (sw[7]) encode_sw = 4'd7;
else if (sw[6]) encode_sw = 4'd6;
else if (sw[5]) encode_sw = 4'd5;
else if (sw[4]) encode_sw = 4'd4;
else if (sw[3]) encode_sw = 4'd3;
else if (sw[2]) encode_sw = 4'd2;
else if (sw[1]) encode_sw = 4'd1;
else encode_sw = 4'd0;
end
endfunction
// Divider only runs while active; resets on load so the first
// tick is always a full interval after the switch is released
always @(posedge clk) begin
if (rst || load)
clk_div <= 27'd0;
else if (active)
clk_div <= clk_div + 1;
end
wire count_tick = active && (clk_div == 27'd99_999_999); // 1 tick per second at
100MHz
always @(posedge clk) begin
if (rst) begin
count <= 4'd0;
end
else if (load) begin
count <= encode_sw(sw_in);
end
else if (count_tick && count > 4'd0) begin
count <= count - 1;
end
end
endmodule
