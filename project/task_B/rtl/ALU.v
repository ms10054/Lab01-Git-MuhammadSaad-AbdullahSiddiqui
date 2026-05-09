`timescale 1ns / 1ps

module ALU_32Bit(
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  ALUControl,
    output wire        carry_flag,
    output reg  [31:0] ALUResult,
    output wire        Zero
);

    always @(*) begin
        case (ALUControl)

            4'b0000: begin
                ALUResult = A & B;          // AND / ANDI
            end

            4'b0001: begin
                ALUResult = A | B;          // OR
            end

            4'b0010: begin
                ALUResult = A ^ B;          // XOR
            end

            4'b0100: begin
                ALUResult = A << B[4:0];    // SLL
            end

            4'b0101: begin
                ALUResult = A >> B[4:0];    // SRL / SRLI
            end

            4'b0110: begin
                ALUResult = A + B;          // ADD / ADDI / LW / SW / JALR
            end

            4'b0111: begin
                ALUResult = A - B;          // SUB / BEQ
            end

            default: begin
                ALUResult = 32'b0;
            end

        endcase
    end

    assign Zero = (ALUResult == 32'b0);
    assign carry_flag = 1'b0;

endmodule