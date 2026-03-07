`timescale 1ns / 1ps

module Fulladder(
    input  wire a,          // 1-bit operand A
    input  wire b,          // 1-bit operand B
    input  wire cin,        // Carry-in from the previous bit slice
    input  wire sub_ctrl,   // Subtraction control: 1 = subtract (invert B), 0 = add
    output wire ALUResult,  // Sum output bit
    output wire cout        // Carry-out to the next bit slice
);
    // When sub_ctrl=1, invert B to form two's complement (XOR with 1)
    wire b_effective;
    assign b_effective = b ^ sub_ctrl;

    // Standard full-adder sum and carry equations
    assign ALUResult = a ^ b_effective ^ cin;
    assign cout = (a & b_effective) | (b_effective & cin) | (a & cin);

endmodule