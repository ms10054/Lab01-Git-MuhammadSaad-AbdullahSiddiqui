`timescale 1ns / 1ps
// ALU Control Unit - Decodes ALU operation based on ALUOp, funct3, and funct7

module ALUControl (
    input  [1:0] aluOp,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg [3:0] aluControlSignal
);

    always @(*) begin
        case (aluOp)
            2'b00: aluControlSignal = 4'b0010; // Load/Store → ADD

            2'b01: aluControlSignal = 4'b0110; // Branch     → SUB

            2'b10: begin
                case ({funct7, funct3})
                    10'b0000000_000: aluControlSignal = 4'b0010; // ADD
                    10'b0100000_000: aluControlSignal = 4'b0110; // SUB
                    10'b0000000_111: aluControlSignal = 4'b0000; // AND
                    10'b0000000_110: aluControlSignal = 4'b0001; // OR
                    10'b0000000_100: aluControlSignal = 4'b0011; // XOR
                    10'b0000000_001: aluControlSignal = 4'b0100; // SLL
                    10'b0000000_101: aluControlSignal = 4'b0101; // SRL
                    default:         aluControlSignal = 4'b0000;
                endcase
            end

            default: aluControlSignal = 4'b0000;
        endcase
    end

endmodule