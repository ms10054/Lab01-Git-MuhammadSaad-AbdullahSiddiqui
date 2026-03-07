`timescale 1ns / 1ps

module ALU_32Bit(
    input  wire [31:0] A,           // 32-bit operand A
    input  wire [31:0] B,           // 32-bit operand B
    input  wire [3:0]  ALUControl,  // Operation selector (see table above)
    output wire        carry_flag,  // Carry-out from MSB (or shift-out bit)
    output wire [31:0] ALUResult,   // 32-bit operation result
    output wire        Zero         // High when ALUResult == 32'b0
);

    // ── Internal carry/shift propagation chain ────────────────
    // carry_chain[i] carries the result of slice i into slice i+1.
    wire [31:0] carry_chain;

    // ── Ripple result wires before shift mux ─────────────────
    wire [31:0] ripple_result;

    // ── Shift path: arithmetic right shift (sign-extend) ─────
    // For SRL (Control == 3'b101), use a dedicated 1-bit right shift
    // that replicates the sign bit (A[31]) into the MSB position.
    wire        is_shift_right;
    wire [31:0] shift_right_result;

    assign is_shift_right   = (ALUControl[2:0] == 3'b101);
    assign shift_right_result = {A[31], A[31:1]};  // Arithmetic right shift by 1

    // ── Carry-in injection for bit 0 ──────────────────────────
    // For SUB (ALUControl[0]=1), two's complement requires cin=1 at bit 0.
    // ALUControl[0] doubles as the sub flag AND the initial carry-in.
    wire initial_carry_in;
    assign initial_carry_in = ALUControl[0];  // 1 for SUB, 0 for ADD

    // ── 32 × 1-bit ALU slices (ripple-carry chain) ───────────
    // Each slice receives the carry-out of the previous slice.
    // Slice 0 gets the initial carry-in injected via ALUControl[3].
    // We reconstruct the control for slice 0 to embed carry_in:
    //   control = {initial_carry_in, ALUControl[2:0]}

    ALU ALU0  (.a(A[0]),  .b(B[0]),  .ALUControl({initial_carry_in,  ALUControl[2:0]}), .carry_out(carry_chain[0]),  .ALUResult(ripple_result[0]));
    ALU ALU1  (.a(A[1]),  .b(B[1]),  .ALUControl({carry_chain[0],    ALUControl[2:0]}), .carry_out(carry_chain[1]),  .ALUResult(ripple_result[1]));
    ALU ALU2  (.a(A[2]),  .b(B[2]),  .ALUControl({carry_chain[1],    ALUControl[2:0]}), .carry_out(carry_chain[2]),  .ALUResult(ripple_result[2]));
    ALU ALU3  (.a(A[3]),  .b(B[3]),  .ALUControl({carry_chain[2],    ALUControl[2:0]}), .carry_out(carry_chain[3]),  .ALUResult(ripple_result[3]));
    ALU ALU4  (.a(A[4]),  .b(B[4]),  .ALUControl({carry_chain[3],    ALUControl[2:0]}), .carry_out(carry_chain[4]),  .ALUResult(ripple_result[4]));
    ALU ALU5  (.a(A[5]),  .b(B[5]),  .ALUControl({carry_chain[4],    ALUControl[2:0]}), .carry_out(carry_chain[5]),  .ALUResult(ripple_result[5]));
    ALU ALU6  (.a(A[6]),  .b(B[6]),  .ALUControl({carry_chain[5],    ALUControl[2:0]}), .carry_out(carry_chain[6]),  .ALUResult(ripple_result[6]));
    ALU ALU7  (.a(A[7]),  .b(B[7]),  .ALUControl({carry_chain[6],    ALUControl[2:0]}), .carry_out(carry_chain[7]),  .ALUResult(ripple_result[7]));
    ALU ALU8  (.a(A[8]),  .b(B[8]),  .ALUControl({carry_chain[7],    ALUControl[2:0]}), .carry_out(carry_chain[8]),  .ALUResult(ripple_result[8]));
    ALU ALU9  (.a(A[9]),  .b(B[9]),  .ALUControl({carry_chain[8],    ALUControl[2:0]}), .carry_out(carry_chain[9]),  .ALUResult(ripple_result[9]));
    ALU ALU10 (.a(A[10]), .b(B[10]), .ALUControl({carry_chain[9],    ALUControl[2:0]}), .carry_out(carry_chain[10]), .ALUResult(ripple_result[10]));
    ALU ALU11 (.a(A[11]), .b(B[11]), .ALUControl({carry_chain[10],   ALUControl[2:0]}), .carry_out(carry_chain[11]), .ALUResult(ripple_result[11]));
    ALU ALU12 (.a(A[12]), .b(B[12]), .ALUControl({carry_chain[11],   ALUControl[2:0]}), .carry_out(carry_chain[12]), .ALUResult(ripple_result[12]));
    ALU ALU13 (.a(A[13]), .b(B[13]), .ALUControl({carry_chain[12],   ALUControl[2:0]}), .carry_out(carry_chain[13]), .ALUResult(ripple_result[13]));
    ALU ALU14 (.a(A[14]), .b(B[14]), .ALUControl({carry_chain[13],   ALUControl[2:0]}), .carry_out(carry_chain[14]), .ALUResult(ripple_result[14]));
    ALU ALU15 (.a(A[15]), .b(B[15]), .ALUControl({carry_chain[14],   ALUControl[2:0]}), .carry_out(carry_chain[15]), .ALUResult(ripple_result[15]));
    ALU ALU16 (.a(A[16]), .b(B[16]), .ALUControl({carry_chain[15],   ALUControl[2:0]}), .carry_out(carry_chain[16]), .ALUResult(ripple_result[16]));
    ALU ALU17 (.a(A[17]), .b(B[17]), .ALUControl({carry_chain[16],   ALUControl[2:0]}), .carry_out(carry_chain[17]), .ALUResult(ripple_result[17]));
    ALU ALU18 (.a(A[18]), .b(B[18]), .ALUControl({carry_chain[17],   ALUControl[2:0]}), .carry_out(carry_chain[18]), .ALUResult(ripple_result[18]));
    ALU ALU19 (.a(A[19]), .b(B[19]), .ALUControl({carry_chain[18],   ALUControl[2:0]}), .carry_out(carry_chain[19]), .ALUResult(ripple_result[19]));
    ALU ALU20 (.a(A[20]), .b(B[20]), .ALUControl({carry_chain[19],   ALUControl[2:0]}), .carry_out(carry_chain[20]), .ALUResult(ripple_result[20]));
    ALU ALU21 (.a(A[21]), .b(B[21]), .ALUControl({carry_chain[20],   ALUControl[2:0]}), .carry_out(carry_chain[21]), .ALUResult(ripple_result[21]));
    ALU ALU22 (.a(A[22]), .b(B[22]), .ALUControl({carry_chain[21],   ALUControl[2:0]}), .carry_out(carry_chain[22]), .ALUResult(ripple_result[22]));
    ALU ALU23 (.a(A[23]), .b(B[23]), .ALUControl({carry_chain[22],   ALUControl[2:0]}), .carry_out(carry_chain[23]), .ALUResult(ripple_result[23]));
    ALU ALU24 (.a(A[24]), .b(B[24]), .ALUControl({carry_chain[23],   ALUControl[2:0]}), .carry_out(carry_chain[24]), .ALUResult(ripple_result[24]));
    ALU ALU25 (.a(A[25]), .b(B[25]), .ALUControl({carry_chain[24],   ALUControl[2:0]}), .carry_out(carry_chain[25]), .ALUResult(ripple_result[25]));
    ALU ALU26 (.a(A[26]), .b(B[26]), .ALUControl({carry_chain[25],   ALUControl[2:0]}), .carry_out(carry_chain[26]), .ALUResult(ripple_result[26]));
    ALU ALU27 (.a(A[27]), .b(B[27]), .ALUControl({carry_chain[26],   ALUControl[2:0]}), .carry_out(carry_chain[27]), .ALUResult(ripple_result[27]));
    ALU ALU28 (.a(A[28]), .b(B[28]), .ALUControl({carry_chain[27],   ALUControl[2:0]}), .carry_out(carry_chain[28]), .ALUResult(ripple_result[28]));
    ALU ALU29 (.a(A[29]), .b(B[29]), .ALUControl({carry_chain[28],   ALUControl[2:0]}), .carry_out(carry_chain[29]), .ALUResult(ripple_result[29]));
    ALU ALU30 (.a(A[30]), .b(B[30]), .ALUControl({carry_chain[29],   ALUControl[2:0]}), .carry_out(carry_chain[30]), .ALUResult(ripple_result[30]));
    ALU ALU31 (.a(A[31]), .b(B[31]), .ALUControl({carry_chain[30],   ALUControl[2:0]}), .carry_out(carry_chain[31]), .ALUResult(ripple_result[31]));

    // ── Output mux: choose between ripple result and shift path ──
    // When SRL is selected, use the dedicated arithmetic-right-shift
    // output; otherwise use the ripple-carry chain result.
    assign ALUResult  = is_shift_right ? shift_right_result : ripple_result;

    // carry_flag reports the MSB carry-out or the shifted-out LSB for SRL
    assign carry_flag = is_shift_right ? A[0] : carry_chain[31];

    // Zero flag: true when all 32 result bits are 0 (used for BEQ)
    assign Zero = (ALUResult == 32'b0);

endmodule