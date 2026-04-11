module branchAdder (
    input  wire [31:0] pc,
    input  wire [31:0] imm,          // sign-extended immediate from immGen
    output wire [31:0] branch_target
);
    // Branch target = PC + (sign-extended immediate << 1)
    assign branch_target = pc + (imm << 1);

endmodule