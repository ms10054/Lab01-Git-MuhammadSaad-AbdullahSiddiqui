`timescale 1ns / 1ps

module immGen(
    input  wire [31:0] instruction,
    output reg  [31:0] imm_out
);

    wire [6:0] opcode;
    wire [2:0] funct3;

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];

    always @(*) begin
        case (opcode)

            // I-type arithmetic: ADDI, ANDI, SRLI
            7'b0010011: begin
                // For SRLI, immediate is shamt in instruction[24:20].
                // Zero-extend shift amount.
                if (funct3 == 3'b101)
                    imm_out = {27'b0, instruction[24:20]};
                else
                    imm_out = {{20{instruction[31]}}, instruction[31:20]};
            end

            // LW
            7'b0000011: begin
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            end

            // JALR
            7'b1100111: begin
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            end

            // SW
            7'b0100011: begin
                imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            // BEQ
            7'b1100011: begin
                imm_out = {{19{instruction[31]}},
                           instruction[31],
                           instruction[7],
                           instruction[30:25],
                           instruction[11:8],
                           1'b0};
            end

            // JAL
            7'b1101111: begin
                imm_out = {{11{instruction[31]}},
                           instruction[31],
                           instruction[19:12],
                           instruction[20],
                           instruction[30:21],
                           1'b0};
            end

            // LUI
            7'b0110111: begin
                imm_out = {instruction[31:12], 12'b0};
            end

            default: begin
                imm_out = 32'b0;
            end

        endcase
    end

endmodule