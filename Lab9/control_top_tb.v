module control_top_tb;
    // -----------------------------
    // Testbench Signals
    // -----------------------------
    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg  [6:0] funct7;

    wire       regWrite;
    wire       memRead;
    wire       memWrite;
    wire       aluSrc;
    wire       memToReg;
    wire       branch;
    wire [3:0] aluControl;

    // -----------------------------
    // DUT Instantiation
    // -----------------------------
control_top dut (
    .opcode     (opcode),
    .funct3     (funct3),
    .funct7     (funct7),
    .regWrite   (regWrite),
    .memRead    (memRead),
    .memWrite   (memWrite),
    .aluSrc     (aluSrc),
    .memToReg   (memToReg),  
    .branch     (branch),
    .aluControl (aluControl)
);

    // -----------------------------
    // Task: Apply Instruction and Display Result
    // -----------------------------
    task apply_and_check;
        input [6:0] op;
        input [2:0] f3;
        input [6:0] f7;
        input [8*20:1] instr_name;   // Instruction name for display
        begin
            opcode = op;
            funct3 = f3;
            funct7 = f7;
            #10;  // Wait for combinational logic to settle

            $display("--------------------------------------------------");
            $display("Instruction : %s", instr_name);
            $display("Opcode = %b, funct3 = %b, funct7 = %b", opcode, funct3, funct7);
            $display("RegWrite=%b | MemRead=%b | MemWrite=%b | ALUSrc=%b | MemtoReg=%b | Branch=%b | ALUControl=%b",
                     regWrite, memRead, memWrite, aluSrc, memToReg, branch, aluControl);
            $display("--------------------------------------------------");
        end
    endtask

    // -----------------------------
    // Main Test Sequence
    // -----------------------------
    initial begin
        $display("=============================================================");
        $display("          CONTROL UNIT TESTBENCH - STARTED");
        $display("=============================================================\n");
;

        $display("--- R-TYPE INSTRUCTIONS ---\n");

        apply_and_check(7'b0110011, 3'b000, 7'b0000000, "ADD");
        apply_and_check(7'b0110011, 3'b000, 7'b0100000, "SUB");
        apply_and_check(7'b0110011, 3'b111, 7'b0000000, "AND");
        apply_and_check(7'b0110011, 3'b110, 7'b0000000, "OR");
        apply_and_check(7'b0110011, 3'b100, 7'b0000000, "XOR");
        apply_and_check(7'b0110011, 3'b001, 7'b0000000, "SLL");
        apply_and_check(7'b0110011, 3'b101, 7'b0000000, "SRL");

        $display("\n--- I-TYPE INSTRUCTIONS ---\n");

        apply_and_check(7'b0010011, 3'b000, 7'b0000000, "ADDI");

        $display("\n--- LOAD INSTRUCTIONS ---\n");

        apply_and_check(7'b0000011, 3'b010, 7'b0000000, "LW");

        $display("\n--- STORE INSTRUCTIONS ---\n");

        apply_and_check(7'b0100011, 3'b010, 7'b0000000, "SW");

        $display("\n--- BRANCH INSTRUCTIONS ---\n");

        apply_and_check(7'b1100011, 3'b000, 7'b0000000, "BEQ");


        $display("\n=============================================================");
        $display("          CONTROL UNIT TESTBENCH - COMPLETED");
        $display("=============================================================");

        #50;
        $finish;
    end

endmodule
