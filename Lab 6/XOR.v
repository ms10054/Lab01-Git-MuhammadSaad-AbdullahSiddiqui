`timescale 1ns / 1ps

module XOR(
    input  wire A,          // First 1-bit operand
    input  wire B,          // Second 1-bit operand
    output wire ALUResult   // Output: A XOR B (implemented at gate level)
);
    assign ALUResult = (A | B) & (~A | ~B);

endmodule