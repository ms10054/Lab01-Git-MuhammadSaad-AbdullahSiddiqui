`timescale 1ns / 1ps

module AND(
    input  wire A,          // First 1-bit operand
    input  wire B,          // Second 1-bit operand
    output wire ALUResult   // Output: A AND B
);
    assign ALUResult = A & B;

endmodule