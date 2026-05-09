`timescale 1ns / 1ps

module MainControl (
    input [6:0] opcode,
    output reg regWrite,
    output reg memRead,
    output reg memWrite,
    output reg aluSrc,
    output reg memToReg,
    output reg branch,
    output reg jal,
    output reg lui,
    output reg [1:0] aluOp
);

always @(*) begin

    regWrite = 1'b0;
    memRead  = 1'b0;
    memWrite = 1'b0;
    aluSrc   = 1'b0;
    memToReg = 1'b0;
    branch   = 1'b0;
    jal      = 1'b0;
    lui      = 1'b0;
    aluOp    = 2'b00;

    case (opcode)

        // R-type: ADD, SUB, AND, OR, XOR, SLL, SRL
        7'b0110011: begin
            regWrite = 1'b1;
            aluSrc   = 1'b0;
            aluOp    = 2'b10;
        end

        // I-type arithmetic: ADDI, ANDI
        7'b0010011: begin
            regWrite = 1'b1;
            aluSrc   = 1'b1;
            memToReg = 1'b0;
            aluOp    = 2'b11;
        end

        // LW
        7'b0000011: begin
            regWrite = 1'b1;
            memRead  = 1'b1;
            aluSrc   = 1'b1;
            memToReg = 1'b1;
            aluOp    = 2'b00; // ADD for address calculation
        end

        // SW
        7'b0100011: begin
            regWrite = 1'b0;
            memRead  = 1'b0;
            memWrite = 1'b1;
            aluSrc   = 1'b1;
            memToReg = 1'b0;
            branch   = 1'b0;
            jal      = 1'b0;
            lui      = 1'b0;
            aluOp    = 2'b00; // ADD for address calculation
        end

        // BEQ and BNE
        7'b1100011: begin
            regWrite = 1'b0;
            memRead  = 1'b0;
            memWrite = 1'b0;
            aluSrc   = 1'b0;
            memToReg = 1'b0;
            branch   = 1'b1;
            jal      = 1'b0;
            lui      = 1'b0;
            aluOp    = 2'b01; // SUB for comparison
        end

        // JAL
        7'b1101111: begin
            regWrite = 1'b1;
            memRead  = 1'b0;
            memWrite = 1'b0;
            aluSrc   = 1'b0;
            memToReg = 1'b0;
            branch   = 1'b0;
            jal      = 1'b1;
            lui      = 1'b0;
            aluOp    = 2'b00;
        end

        // JALR
        7'b1100111: begin
            regWrite = 1'b1;
            memRead  = 1'b0;
            memWrite = 1'b0;
            aluSrc   = 1'b1;
            memToReg = 1'b0;
            branch   = 1'b0;
            jal      = 1'b0;
            lui      = 1'b0;
            aluOp    = 2'b00; // ADD rs1 + imm
        end

        // LUI
        7'b0110111: begin
            regWrite = 1'b1;
            memRead  = 1'b0;
            memWrite = 1'b0;
            aluSrc   = 1'b0;
            memToReg = 1'b0;
            branch   = 1'b0;
            jal      = 1'b0;
            lui      = 1'b1;
            aluOp    = 2'b00;
        end

        default: begin
            regWrite = 1'b0;
            memRead  = 1'b0;
            memWrite = 1'b0;
            aluSrc   = 1'b0;
            memToReg = 1'b0;
            branch   = 1'b0;
            jal      = 1'b0;
            lui      = 1'b0;
            aluOp    = 2'b00;
        end

    endcase
end

endmodule