module immGen (
    input  wire [31:0] instruction,
    output reg  [31:0] imm_out
);
    wire [6:0] opcode = instruction[6:0];

    // Opcode constants
    localparam I_TYPE_LOAD   = 7'b0000011; // lw, lb, lh ...
    localparam I_TYPE_ALU    = 7'b0010011; // addi, slti, xori ...
    localparam I_TYPE_JALR   = 7'b1100111; // jalr
    localparam S_TYPE        = 7'b0100011; // sw, sb, sh
    localparam B_TYPE        = 7'b1100011; // beq, bne, blt, bge ...

    always @(*) begin
        case (opcode)

            // I-type: imm[11:0] = inst[31:20], sign-extended
            I_TYPE_LOAD,
            I_TYPE_ALU,
            I_TYPE_JALR: begin
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-type: imm[11:5] = inst[31:25], imm[4:0] = inst[11:7]
            S_TYPE: begin
                imm_out = {{20{instruction[31]}},
                           instruction[31:25],
                           instruction[11:7]};
            end

            // B-type: imm[12|10:5] = inst[31:25], imm[4:1|11] = inst[11:7]
            // Note: bit 0 is always 0 (half-word aligned)
            B_TYPE: begin
                imm_out = {{19{instruction[31]}},
                           instruction[31],
                           instruction[7],
                           instruction[30:25],
                           instruction[11:8],
                           1'b0};
            end

            default: imm_out = 32'b0;
        endcase
    end

endmodule