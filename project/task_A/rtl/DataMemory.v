`timescale 1ns / 1ps

module DataMemory (
    input  wire        clk,
    input  wire        rst,
    input  wire        MemRead,
    input  wire        MemWrite,
    input  wire [31:0] address,
    input  wire [31:0] WriteData,
    output reg  [31:0] ReadData
);

    // 256 words = 1024 bytes
    reg [31:0] memory [0:255];

    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end

    // Synchronous write
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 256; i = i + 1) begin
                memory[i] <= 32'b0;
            end
        end else begin
            if (MemWrite) begin
                memory[address[9:2]] <= WriteData;
            end
        end
    end

    // Combinational read
    always @(*) begin
        if (MemRead) begin
            ReadData = memory[address[9:2]];
        end else begin
            ReadData = 32'b0;
        end
    end

endmodule