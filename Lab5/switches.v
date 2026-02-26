`timescale 1ns / 1ps
module switches (
input wire clk,
input wire rst,
input wire [15:0] btns, // unused
input wire [15:0] switches,
input wire readEnable,
output reg [31:0] readData,
input wire [31:0] writeData,
input wire writeEnable,
input wire [29:0] memAddress
);
always @(*) begin
if (readEnable) begin
readData = {16'b0, switches};
end else begin
readData = 32'b0;
end
end
endmodule