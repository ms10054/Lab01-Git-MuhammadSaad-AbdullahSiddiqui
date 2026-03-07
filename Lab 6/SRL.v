`timescale 1ns / 1ps

module SRL(
    input  wire A,          // Current bit of operand A (passed as carry-out)
    input  wire shift_in,   // Bit shifted in from the left (carry-in from higher slice)
    output wire ALUResult,  // Shifted result bit (receives shift_in)
    output wire carry_out   // Bit forwarded to the next lower slice
);
    // The shifted-in value becomes the result bit at this position
    assign ALUResult  = shift_in;
    // The current bit is forwarded as carry to the next lower position
    assign carry_out = A;

endmodule