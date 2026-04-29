`timescale 1ns / 1ps
// Main Control Unit - Generates control signals for the datapath

module MainControl (
    input  [6:0] opcode,
    output reg       regWrite,
    output reg       memRead,
    output reg       memWrite,
    output reg       aluSrc,
    output reg       memToReg,
    output reg       branch,
    output reg [1:0] aluOp
);

    always @(*) begin
        case (opcode)
            // R-type instructions
            7'b0110011: begin
                regWrite = 1'b1;  memRead = 1'b0;  memWrite = 1'b0;
                aluSrc   = 1'b0;  memToReg = 1'b0; branch   = 1'b0;
                aluOp    = 2'b10;
            end

            // I-type (ADDI) and Load (LW)
            7'b0010011, 7'b0000011: begin
                regWrite = 1'b1;
                memRead  = (opcode == 7'b0000011);
                memWrite = 1'b0;
                aluSrc   = 1'b1;
                memToReg = (opcode == 7'b0000011);
                branch   = 1'b0;
                aluOp    = 2'b00;
            end

            // Store (SW)
            7'b0100011: begin
                regWrite = 1'b0;  memRead = 1'b0;  memWrite = 1'b1;
                aluSrc   = 1'b1;  memToReg = 1'b0; branch   = 1'b0;
                aluOp    = 2'b00;
            end

            // Branch (BEQ)
            7'b1100011: begin
                regWrite = 1'b0;  memRead = 1'b0;  memWrite = 1'b0;
                aluSrc   = 1'b0;  memToReg = 1'b0; branch   = 1'b1;
                aluOp    = 2'b01;
            end

            default: begin
                regWrite = 1'b0; memRead = 1'b0; memWrite = 1'b0;
                aluSrc   = 1'b0; memToReg= 1'b0; branch   = 1'b0;
                aluOp    = 2'b00;
            end
        endcase
    end

endmodule
