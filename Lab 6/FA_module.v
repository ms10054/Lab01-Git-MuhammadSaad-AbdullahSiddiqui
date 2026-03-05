`timescale 1ns / 1ps
module Fulladder(
    input wire a,
    input wire b,
    input wire cin,
    input wire signal,
    output wire y,
    output wire cout
    );
    
    wire b_controlled;
    
    assign b_controlled = b ^ signal;  
    assign y    = a ^ b_controlled ^ cin;
    assign cout = (a & b_controlled) | (b_controlled & cin) | (a & cin);
    
endmodule
