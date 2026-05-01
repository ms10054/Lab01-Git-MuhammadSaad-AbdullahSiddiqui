`timescale 1ns / 1ps

module ALUControl(
    input  wire [1:0] aluOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] aluControlSignal
);

    always @(*) begin
        case (aluOp)

            // LW, SW, ADDI, JALR address calculation
            // In YOUR ALU: 4'b0110 = ADD
            2'b00: begin
                aluControlSignal = 4'b0110;
            end

            // BEQ / BNE comparison
            // In YOUR ALU: 4'b0111 = SUB
            2'b01: begin
                aluControlSignal = 4'b0111;
            end

            // R-type instructions
            2'b10: begin
                case (funct3)

                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            aluControlSignal = 4'b0111; // SUB
                        else
                            aluControlSignal = 4'b0110; // ADD
                    end

                    3'b111: aluControlSignal = 4'b0000; // AND
                    3'b110: aluControlSignal = 4'b0001; // OR
                    3'b100: aluControlSignal = 4'b0010; // XOR
                    3'b001: aluControlSignal = 4'b0100; // SLL
                    3'b101: aluControlSignal = 4'b0101; // SRL

                    default: aluControlSignal = 4'b0110; // ADD
                endcase
            end

            default: begin
                aluControlSignal = 4'b0110; // ADD
            end

        endcase
    end

endmodule