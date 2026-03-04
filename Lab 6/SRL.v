`timescale 1ns / 1ps

module SRL(
    input wire A,
    input wire signal_in,
    output wire Z,
    output wire signal_out
    );
    
    assign signal_out = A;
    assign Z = signal_in;
    
endmodule
