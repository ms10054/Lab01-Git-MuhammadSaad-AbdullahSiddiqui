`timescale 1ns / 1ps

module SRL(
    input wire A,
    input wire signal_in,
    output wire Z,
    output wire signal_out
    );
    
<<<<<<< HEAD
    assign signal_out = A;
    assign Z = signal_in;
    
=======
assign Z = A >> 1;
>>>>>>> c819f6a5e31fcd34605a9e0e05cf39c64e0cb6fc
endmodule
