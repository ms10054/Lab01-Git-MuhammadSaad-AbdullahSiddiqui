`timescale 1ns / 1ps
// Top Control Module - Combines Main Control and ALU Control

module control_top (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,

    output       regWrite,
    output       memRead,
    output       memWrite,
    output       aluSrc,
    output       memToReg,
    output       branch,
    output [3:0] aluControl
);

    wire [1:0] aluOp;

    MainControl mainCtrl (
        .opcode   (opcode),
        .regWrite (regWrite),
        .memRead  (memRead),
        .memWrite (memWrite),
        .aluSrc   (aluSrc),
        .memToReg (memToReg),
        .branch   (branch),
        .aluOp    (aluOp)
    );

    ALUControl aluCtrl (
        .aluOp          (aluOp),
        .funct3         (funct3),
        .funct7         (funct7),
        .aluControlSignal (aluControl)
    );

endmodule
