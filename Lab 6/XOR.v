`timescale 1ns / 1ps

module XOR(
    input  wire A,
    input  wire B,
    output Z
);
    
assign Z = (A | B) & (~A | ~B);
endmodule