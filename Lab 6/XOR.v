`timescale 1ns / 1ps

module XOR(
    input  wire [31:0] A,
    input  wire [31:0] B,
    output [31:0] Z
);
    
assign Z = (A | B) & (~A | ~B);
endmodule