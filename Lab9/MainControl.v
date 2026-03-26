`timescale 1ns / 1ps

module MainControl (
    input  wire [6:0] opcode,
    output reg        RegWrite,
    output reg        ALUSrc,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        MemtoReg,
    output reg        Branch,
    output reg [1:0]  ALUOp
);

    // RISC-V RV32I Opcodes
    localparam R_TYPE = 7'b0110011;  // ADD, SUB, SLL, SRL, AND, OR, XOR
    localparam I_ALU  = 7'b0010011;  // ADDI
    localparam I_LOAD = 7'b0000011;  // LW, LH, LB
    localparam S_TYPE = 7'b0100011;  // SW, SH, SB
    localparam B_TYPE = 7'b1100011;  // BEQ

    // ALUOp encoding:
    //   2'b00 -> ADD (used for loads/stores/ADDI address calc)
    //   2'b01 -> SUB (used for BEQ comparison)
    //   2'b10 -> use funct3/funct7 (R-type)
    //   2'b11 -> use funct3 only (I-type ALU: ADDI)

    always @(*) begin
        // Safe defaults (don't-care fields set to 0)
        RegWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemtoReg = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)
            R_TYPE: begin
                // ADD, SUB, SLL, SRL, AND, OR, XOR
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;  // second operand from register
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;  // write ALU result to register
                Branch   = 1'b0;
                ALUOp    = 2'b10; // decode via funct3/funct7
            end

            I_ALU: begin
                // ADDI
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;  // second operand is immediate
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b11; // decode via funct3 only
            end

            I_LOAD: begin
                // LW, LH, LB
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;  // add immediate offset to base address
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                MemtoReg = 1'b1;  // write memory data to register
                Branch   = 1'b0;
                ALUOp    = 2'b00; // always ADD for address calculation
            end

            S_TYPE: begin
                // SW, SH, SB
                RegWrite = 1'b0;
                ALUSrc   = 1'b1;  // add immediate offset to base address
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                MemtoReg = 1'b0;  // don't care (no register write)
                Branch   = 1'b0;
                ALUOp    = 2'b00; // always ADD for address calculation
            end

            B_TYPE: begin
                // BEQ
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;  // compare two registers
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;  // don't care (no register write)
                Branch   = 1'b1;
                ALUOp    = 2'b01; // SUB to compare (zero flag used)
            end

            default: begin
                // Unsupported opcode: all signals go to safe 0 defaults
                RegWrite = 1'b0;
                ALUSrc   = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end
        endcase
    end

endmodule
