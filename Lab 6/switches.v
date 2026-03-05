`timescale 1ns / 1ps

module switches(
    input clk,
    input rst,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,
    output reg [31:0] readData = 0,
    output reg [15:0] leds
    );
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            readData <= 32'd0;
            leds     <= 16'd0;
        end else begin
            readData <= 32'd0;
            leds     <= 16'd0;
        end
    end
    
endmodule