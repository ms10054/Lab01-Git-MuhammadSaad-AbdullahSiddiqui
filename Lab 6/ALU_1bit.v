`timescale 1ns / 1ps

module ALU_1bit (
    input  wire a,          // 1-bit operand A
    input  wire b,          // 1-bit operand B (for SUB: already ~B from top level)
    input  wire cin,        // carry-in from previous bit (LSB has cin=1 for SUB)
    input  wire [2:0] select, // operation select
    output reg  result,     // 1-bit result of selected operation
    output wire cout        // carry-out to next bit (always from full adder)
);

    // Full Adder logic (always computed)
    wire sum;   // a ⊕ b ⊕ cin
    wire carry; // majority function

    assign sum   = a ^ b ^ cin;
    assign carry = (a & b) | (a & cin) | (b & cin);

    // Carry-out is always the full adder's carry - keeps chain uniform
    assign cout = carry;

    // Operation multiplexer
    always @(*) begin
        case (select)
            3'b000:  result = sum;          // ADD
            3'b001:  result = sum;          // SUB (b already inverted, cin provides +1)
            3'b010:  result = a & b;        // AND
            3'b011:  result = a | b;        // OR
            3'b100:  result = a ^ b;        // XOR
            default: result = 1'b0;         // invalid → 0 (safe default)
        endcase
    end

endmodule