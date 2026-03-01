`timescale 1ns / 1ps

module SLL(
    input [31:0] A,
    output [31:0] Z
    );
    
assign Z = A << 1;
endmodule