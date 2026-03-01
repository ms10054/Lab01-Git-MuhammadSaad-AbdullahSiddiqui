`timescale 1ns / 1ps

module FA_32bit(
    input  [31:0] A,
    input  [31:0] B,
    input         Sub,      // 0 = Add, 1 = Subtract
    output [31:0] S,
    output        Cout    // carry out (unsigned overflow)
);
    // XOR every B bit with Sub to conditionally invert B
    wire [31:0] B_xor;
    xor X0  (B_xor[0],  B[0],  Sub);
    xor X1  (B_xor[1],  B[1],  Sub);
    xor X2  (B_xor[2],  B[2],  Sub);
    xor X3  (B_xor[3],  B[3],  Sub);
    xor X4  (B_xor[4],  B[4],  Sub);
    xor X5  (B_xor[5],  B[5],  Sub);
    xor X6  (B_xor[6],  B[6],  Sub);
    xor X7  (B_xor[7],  B[7],  Sub);
    xor X8  (B_xor[8],  B[8],  Sub);
    xor X9  (B_xor[9],  B[9],  Sub);
    xor X10 (B_xor[10], B[10], Sub);
    xor X11 (B_xor[11], B[11], Sub);
    xor X12 (B_xor[12], B[12], Sub);
    xor X13 (B_xor[13], B[13], Sub);
    xor X14 (B_xor[14], B[14], Sub);
    xor X15 (B_xor[15], B[15], Sub);
    xor X16 (B_xor[16], B[16], Sub);
    xor X17 (B_xor[17], B[17], Sub);
    xor X18 (B_xor[18], B[18], Sub);
    xor X19 (B_xor[19], B[19], Sub);
    xor X20 (B_xor[20], B[20], Sub);
    xor X21 (B_xor[21], B[21], Sub);
    xor X22 (B_xor[22], B[22], Sub);
    xor X23 (B_xor[23], B[23], Sub);
    xor X24 (B_xor[24], B[24], Sub);
    xor X25 (B_xor[25], B[25], Sub);
    xor X26 (B_xor[26], B[26], Sub);
    xor X27 (B_xor[27], B[27], Sub);
    xor X28 (B_xor[28], B[28], Sub);
    xor X29 (B_xor[29], B[29], Sub);
    xor X30 (B_xor[30], B[30], Sub);
    xor X31 (B_xor[31], B[31], Sub);

    // Internal carry chain C[0..30] + final carry C31 (= Cout)
    wire [30:0] C;          // C[0] = carry out of bit 0, ... C[30] = carry out of bit 30
    wire        C31;        // carry out of bit 31 = Cout

    // FA0: carry-in = Sub  (0 for add, 1 for subtract ? +1 for two's complement)
    Fulladder FA0  (A[0],  B_xor[0],  Sub,   S[0],  C[0]);
    Fulladder FA1  (A[1],  B_xor[1],  C[0],  S[1],  C[1]);
    Fulladder FA2  (A[2],  B_xor[2],  C[1],  S[2],  C[2]);
    Fulladder FA3  (A[3],  B_xor[3],  C[2],  S[3],  C[3]);
    Fulladder FA4  (A[4],  B_xor[4],  C[3],  S[4],  C[4]);
    Fulladder FA5  (A[5],  B_xor[5],  C[4],  S[5],  C[5]);
    Fulladder FA6  (A[6],  B_xor[6],  C[5],  S[6],  C[6]);
    Fulladder FA7  (A[7],  B_xor[7],  C[6],  S[7],  C[7]);
    Fulladder FA8  (A[8],  B_xor[8],  C[7],  S[8],  C[8]);
    Fulladder FA9  (A[9],  B_xor[9],  C[8],  S[9],  C[9]);
    Fulladder FA10 (A[10], B_xor[10], C[9],  S[10], C[10]);
    Fulladder FA11 (A[11], B_xor[11], C[10], S[11], C[11]);
    Fulladder FA12 (A[12], B_xor[12], C[11], S[12], C[12]);
    Fulladder FA13 (A[13], B_xor[13], C[12], S[13], C[13]);
    Fulladder FA14 (A[14], B_xor[14], C[13], S[14], C[14]);
    Fulladder FA15 (A[15], B_xor[15], C[14], S[15], C[15]);
    Fulladder FA16 (A[16], B_xor[16], C[15], S[16], C[16]);
    Fulladder FA17 (A[17], B_xor[17], C[16], S[17], C[17]);
    Fulladder FA18 (A[18], B_xor[18], C[17], S[18], C[18]);
    Fulladder FA19 (A[19], B_xor[19], C[18], S[19], C[19]);
    Fulladder FA20 (A[20], B_xor[20], C[19], S[20], C[20]);
    Fulladder FA21 (A[21], B_xor[21], C[20], S[21], C[21]);
    Fulladder FA22 (A[22], B_xor[22], C[21], S[22], C[22]);
    Fulladder FA23 (A[23], B_xor[23], C[22], S[23], C[23]);
    Fulladder FA24 (A[24], B_xor[24], C[23], S[24], C[24]);
    Fulladder FA25 (A[25], B_xor[25], C[24], S[25], C[25]);
    Fulladder FA26 (A[26], B_xor[26], C[25], S[26], C[26]);
    Fulladder FA27 (A[27], B_xor[27], C[26], S[27], C[27]);
    Fulladder FA28 (A[28], B_xor[28], C[27], S[28], C[28]);
    Fulladder FA29 (A[29], B_xor[29], C[28], S[29], C[29]);
    Fulladder FA30 (A[30], B_xor[30], C[29], S[30], C[30]);
    Fulladder FA31 (A[31], B_xor[31], C[30], S[31], C31);
    assign Cout = C31;
endmodule