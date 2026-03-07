`timescale 1ns / 1ps

module OR(
    input  wire A,          // First 1-bit operand
    input  wire B,          // Second 1-bit operand
    output wire ALUResult   // Output: A OR B
);
    assign ALUResult = A | B;

endmodule