`timescale 1ns / 1ps

module OR (
    input  wire A,
    input  wire B,
    output Z
);

assign Z = A | B;
endmodule