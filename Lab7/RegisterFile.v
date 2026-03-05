`timescale 1ns / 1ps

module RegisterFile (
    input             clk,
    input             rst,
    input             WriteEnable,
    input      [4:0]  rs1,
    input      [4:0]  rs2,
    input      [4:0]  rd,
    input      [31:0] WriteData,
    output reg [31:0] ReadData1,
    output reg [31:0] ReadData2
);

    reg [31:0] regs [31:0];
    integer i;

    // Synchronous reset + write
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'd0;
        end else begin
            if (WriteEnable && rd != 5'd0)
                regs[rd] <= WriteData;
        end
    end

    // Asynchronous (combinational) reads
    always @(*) begin
        ReadData1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
        ReadData2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];
    end

endmodule