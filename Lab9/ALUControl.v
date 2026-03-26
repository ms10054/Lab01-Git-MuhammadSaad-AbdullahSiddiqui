`timescale 1ns / 1ps

module ALUControl (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] ALUControl
);

    // ALUControl encodings
    localparam ALU_ADD  = 4'b0000;  // ADD  (also used for address calc)
    localparam ALU_SUB  = 4'b0001;  // SUB  (also used for BEQ compare)
    localparam ALU_SLL  = 4'b0010;  // Shift Left Logical
    localparam ALU_SRL  = 4'b0011;  // Shift Right Logical
    localparam ALU_AND  = 4'b0100;  // AND
    localparam ALU_OR   = 4'b0101;  // OR
    localparam ALU_XOR  = 4'b0110;  // XOR

    // funct3 encodings
    localparam F3_ADD_SUB = 3'b000;
    localparam F3_SLL     = 3'b001;
    localparam F3_SRL     = 3'b101;
    localparam F3_AND     = 3'b111;
    localparam F3_OR      = 3'b110;
    localparam F3_XOR     = 3'b100;

    // funct7 bits that distinguish ADD vs SUB / SRL vs SRA
    localparam F7_ADD_SRL = 7'b0000000;
    localparam F7_SUB     = 7'b0100000;

    always @(*) begin
        // Safe default
        ALUControl = ALU_ADD;

        case (ALUOp)
            2'b00: begin
                // Load / Store: always perform ADD for address calculation
                ALUControl = ALU_ADD;
            end

            2'b01: begin
                // BEQ: always perform SUB (zero flag checked externally)
                ALUControl = ALU_SUB;
            end

            2'b10: begin
                // R-type: decode using funct3 and funct7
                case (funct3)
                    F3_ADD_SUB: begin
                        if (funct7 == F7_SUB)
                            ALUControl = ALU_SUB;  // SUB
                        else
                            ALUControl = ALU_ADD;  // ADD
                    end
                    F3_SLL:  ALUControl = ALU_SLL;
                    F3_SRL:  ALUControl = ALU_SRL;  // only SRL supported (not SRA)
                    F3_AND:  ALUControl = ALU_AND;
                    F3_OR:   ALUControl = ALU_OR;
                    F3_XOR:  ALUControl = ALU_XOR;
                    default: ALUControl = ALU_ADD;  // safe default
                endcase
            end

            2'b11: begin
                // I-type ALU (ADDI): decode using funct3 only (no funct7)
                case (funct3)
                    F3_ADD_SUB: ALUControl = ALU_ADD;  // ADDI always adds
                    default:    ALUControl = ALU_ADD;  // safe default
                endcase
            end

            default: ALUControl = ALU_ADD;
        endcase
    end

endmodule