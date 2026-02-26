`timescale 1ns / 1ps
module led_driver (
input wire clk,
input wire rst,
input wire [31:0] writeData,
input wire writeEnable,
input wire readEnable,
input wire [29:0] memAddress,
output reg [31:0] readData,
output reg [15:0] leds
);
always @(posedge clk) begin
if (rst) begin
leds <= 16'b0;
end
else if (writeEnable) begin
leds <= writeData[15:0];
end
end
always @(*) begin
if (readEnable) begin
readData = {16'b0, leds};
end else begin
readData = 32'b0;
end
end
endmodule