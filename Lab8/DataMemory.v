`timescale 1ns / 1ps

module DataMemory (
    input         clk,
    input         reset,
    input         MemWrite,
    input  [9:0]  address,
    input  [31:0] WriteData,
    output [31:0] ReadData
);
    reg  [31:0] Memory [0:511];
    integer     n;

    wire [7:0] loc = address[7:0];

    always @(posedge clk) begin
        if (reset) begin
            for (n = 0; n < 512; n = n + 1)
                Memory[n] <= n;
        end else if (MemWrite) begin
            Memory[loc] <= WriteData;
        end
    end

    assign ReadData = Memory[loc];
endmodule