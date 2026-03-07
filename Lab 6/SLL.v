`timescale 1ns / 1ps

module SLL(
    input  wire A,          // Current bit of operand A (passed as carry-out)
    input  wire shift_in,   // Bit shifted in from the right (carry-in from lower slice)
    output wire ALUResult,  // Shifted result bit (receives shift_in)
    output wire carry_out   // Bit forwarded to the next higher slice
);
    // The shifted-in value becomes the result bit at this position
    assign ALUResult  = shift_in;
    // The current bit is forwarded as carry to the next higher position
    assign carry_out = A;

endmodule