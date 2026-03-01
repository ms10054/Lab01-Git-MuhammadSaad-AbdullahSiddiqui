`timescale 1ns / 1ps

module OR (
    input  wire [31:0] A,
    input  wire [31:0] B,
    output [31:0] Z
);

assign Z = A | B;
endmodule