`timescale 1ns / 1ps

module ALU(
    input  wire        a,           // 1-bit slice of operand A
    input  wire        b,           // 1-bit slice of operand B
    input  wire [3:0]  ALUControl,  // 4-bit operation selector (see table above)
    output reg         carry_out,   // Carry-out / shift propagation to next slice
    output reg         ALUResult    // 1-bit result of the selected operation
);

    // ── Decompose ALUControl ──────────────────────────────────
    wire carry_in  = ALUControl[3]; // Carry-in from previous slice (or injected by 32-bit top)
    wire sub_ctrl  = ALUControl[0]; // Subtraction flag: 1 = SUB, 0 = ADD

    // ── Intermediate wire results from sub-modules ────────────
    wire and_result;
    wire or_result;
    wire xor_result;

    wire sll_result,  sll_carry;    // Shift-left result and carry
    wire srl_result,  srl_carry;    // Shift-right result and carry
    wire add_result,  add_carry;    // Adder/subtractor result and carry

    // ── Instantiate logic sub-modules ────────────────────────
    AND  and_gate  (.A(a), .B(b), .ALUResult(and_result));
    OR   or_gate   (.A(a), .B(b), .ALUResult(or_result));
    XOR  xor_gate  (.A(a), .B(b), .ALUResult(xor_result));

    SLL  sll_unit  (.A(a), .shift_in(carry_in),
                    .ALUResult(sll_result), .carry_out(sll_carry));

    SRL  srl_unit  (.A(a), .shift_in(carry_in),
                    .ALUResult(srl_result), .carry_out(srl_carry));

    Fulladder adder (.a(a), .b(b), .cin(carry_in), .sub_ctrl(sub_ctrl),
                     .ALUResult(add_result), .cout(add_carry));

    // ── Operation Mux ─────────────────────────────────────────
    // Select ALUResult and carry_out based on ALUControl.
    // Don't-care cases (e.g. 4'b1000) mirror their cin=0 counterparts
    // because the logic gates ignore carry_in entirely.
    always @(*) begin
        case (ALUControl)
            // ── Logic operations (carry_in irrelevant) ────────
            4'b0000,
            4'b1000: begin ALUResult = and_result;  carry_out = 1'b0;      end  // AND

            4'b0001,
            4'b1001: begin ALUResult = or_result;   carry_out = 1'b0;      end  // OR

            4'b0010,
            4'b1010: begin ALUResult = xor_result;  carry_out = 1'b0;      end  // XOR

            // ── Shift operations ──────────────────────────────
            4'b0100,
            4'b1100: begin ALUResult = sll_result;  carry_out = sll_carry; end  // SLL

            4'b0101,
            4'b1101: begin ALUResult = srl_result;  carry_out = srl_carry; end  // SRL

            // ── Arithmetic operations ─────────────────────────
            4'b0110: begin ALUResult = add_result;  carry_out = add_carry; end  // ADD  (cin=0)
            4'b0111: begin ALUResult = add_result;  carry_out = add_carry; end  // SUB  (cin=0, B inverted; top sets cin=1 at bit0)
            4'b1110: begin ALUResult = add_result;  carry_out = add_carry; end  // ADD  (cin=1)
            4'b1111: begin ALUResult = add_result;  carry_out = add_carry; end  // SUB  (cin=1)

            default: begin ALUResult = 1'b0;        carry_out = 1'b0;      end  // Undefined → 0
        endcase
    end

endmodule