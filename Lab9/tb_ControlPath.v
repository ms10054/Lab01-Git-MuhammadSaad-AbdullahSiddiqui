`timescale 1ns / 1ps

module tb_ControlPath;

    // --------------------------------------------------------
    // DUT Signals
    // --------------------------------------------------------
    reg  [6:0] opcode;
    wire       RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;

    reg  [1:0] aluop_in;
    reg  [2:0] funct3;
    reg  [6:0] funct7;
    wire [3:0] ALUControl;

    // --------------------------------------------------------
    // Instantiate DUTs
    // --------------------------------------------------------
    MainControl uut_main (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUSrc   (ALUSrc),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .MemtoReg (MemtoReg),
        .Branch   (Branch),
        .ALUOp    (ALUOp)
    );

    ALUControl uut_alu (
        .ALUOp     (aluop_in),
        .funct3    (funct3),
        .funct7    (funct7),
        .ALUControl(ALUControl)
    );

    // --------------------------------------------------------
    // Opcodes
    // --------------------------------------------------------
    localparam R_TYPE = 7'b0110011;
    localparam I_ALU  = 7'b0010011;
    localparam I_LOAD = 7'b0000011;
    localparam S_TYPE = 7'b0100011;
    localparam B_TYPE = 7'b1100011;

    // funct3 values
    localparam F3_ADD_SUB = 3'b000;
    localparam F3_SLL     = 3'b001;
    localparam F3_SRL     = 3'b101;
    localparam F3_AND     = 3'b111;
    localparam F3_OR      = 3'b110;
    localparam F3_XOR     = 3'b100;
    localparam F3_LW      = 3'b010;
    localparam F3_LH      = 3'b001;
    localparam F3_LB      = 3'b000;
    localparam F3_SW      = 3'b010;
    localparam F3_SH      = 3'b001;
    localparam F3_SB      = 3'b000;
    localparam F3_BEQ     = 3'b000;

    // funct7 values
    localparam F7_NORMAL  = 7'b0000000;
    localparam F7_SUB     = 7'b0100000;

    // --------------------------------------------------------
    // Task: display current state
    // --------------------------------------------------------
    task show_main;
        input [63:0] label; // unused, just for readability
        begin
            $display("  opcode=%b | RegWrite=%b ALUSrc=%b MemRead=%b MemWrite=%b MemtoReg=%b Branch=%b ALUOp=%b",
                      opcode, RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp);
        end
    endtask

    task show_alu;
        input [79:0] label;
        begin
            $display("  ALUOp=%b funct3=%b funct7=%b | ALUControl=%b",
                      aluop_in, funct3, funct7, ALUControl);
        end
    endtask

    // --------------------------------------------------------
    // Stimulus
    // --------------------------------------------------------
    integer pass_count;
    integer fail_count;

    task check_main;
        input [6:0]  op;
        input        exp_RegWrite, exp_ALUSrc, exp_MemRead, exp_MemWrite,
                     exp_MemtoReg, exp_Branch;
        input [1:0]  exp_ALUOp;
        input [127:0] name;
        begin
            opcode = op;
            #10;
            if (RegWrite === exp_RegWrite && ALUSrc === exp_ALUSrc &&
                MemRead === exp_MemRead   && MemWrite === exp_MemWrite &&
                MemtoReg === exp_MemtoReg && Branch === exp_Branch &&
                ALUOp === exp_ALUOp) begin
                $display("  PASS: %s", name);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: %s", name);
                $display("    Expected: RegWrite=%b ALUSrc=%b MemRead=%b MemWrite=%b MemtoReg=%b Branch=%b ALUOp=%b",
                          exp_RegWrite, exp_ALUSrc, exp_MemRead, exp_MemWrite,
                          exp_MemtoReg, exp_Branch, exp_ALUOp);
                $display("    Got:      RegWrite=%b ALUSrc=%b MemRead=%b MemWrite=%b MemtoReg=%b Branch=%b ALUOp=%b",
                          RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task check_alu;
        input [1:0]  aop;
        input [2:0]  f3;
        input [6:0]  f7;
        input [3:0]  exp_ALUCtrl;
        input [127:0] name;
        begin
            aluop_in = aop;
            funct3   = f3;
            funct7   = f7;
            #10;
            if (ALUControl === exp_ALUCtrl) begin
                $display("  PASS: %s  ALUControl=%b", name, ALUControl);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: %s  Expected ALUControl=%b  Got=%b", name, exp_ALUCtrl, ALUControl);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        // Waveform dump
        $dumpfile("tb_ControlPath.vcd");
        $dumpvars(0, tb_ControlPath);

        pass_count = 0;
        fail_count = 0;

        $display("========================================");
        $display("  MAIN CONTROL UNIT TESTS");
        $display("========================================");

        // R-type: RegWrite=1 ALUSrc=0 MemRead=0 MemWrite=0 MemtoReg=0 Branch=0 ALUOp=10
        check_main(R_TYPE, 1,0,0,0,0,0, 2'b10, "R-TYPE (ADD/SUB/SLL/SRL/AND/OR/XOR)");

        // ADDI:   RegWrite=1 ALUSrc=1 MemRead=0 MemWrite=0 MemtoReg=0 Branch=0 ALUOp=11
        check_main(I_ALU,  1,1,0,0,0,0, 2'b11, "ADDI");

        // Load:   RegWrite=1 ALUSrc=1 MemRead=1 MemWrite=0 MemtoReg=1 Branch=0 ALUOp=00
        check_main(I_LOAD, 1,1,1,0,1,0, 2'b00, "LOAD (LW/LH/LB)");

        // Store:  RegWrite=0 ALUSrc=1 MemRead=0 MemWrite=1 MemtoReg=0 Branch=0 ALUOp=00
        check_main(S_TYPE, 0,1,0,1,0,0, 2'b00, "STORE (SW/SH/SB)");

        // BEQ:    RegWrite=0 ALUSrc=0 MemRead=0 MemWrite=0 MemtoReg=0 Branch=1 ALUOp=01
        check_main(B_TYPE, 0,0,0,0,0,1, 2'b01, "BEQ");

        $display("");
        $display("========================================");
        $display("  ALU CONTROL UNIT TESTS");
        $display("========================================");

        // ALUOp=00 (Load/Store) -> ADD (0000)
        check_alu(2'b00, F3_ADD_SUB, F7_NORMAL, 4'b0000, "LW/SW  address ADD");

        // ALUOp=01 (BEQ) -> SUB (0001)
        check_alu(2'b01, F3_BEQ,     F7_NORMAL, 4'b0001, "BEQ    SUB compare");

        // ALUOp=10 (R-type)
        check_alu(2'b10, F3_ADD_SUB, F7_NORMAL, 4'b0000, "ADD    (funct7=0000000)");
        check_alu(2'b10, F3_ADD_SUB, F7_SUB,    4'b0001, "SUB    (funct7=0100000)");
        check_alu(2'b10, F3_SLL,     F7_NORMAL, 4'b0010, "SLL");
        check_alu(2'b10, F3_SRL,     F7_NORMAL, 4'b0011, "SRL");
        check_alu(2'b10, F3_AND,     F7_NORMAL, 4'b0100, "AND");
        check_alu(2'b10, F3_OR,      F7_NORMAL, 4'b0101, "OR");
        check_alu(2'b10, F3_XOR,     F7_NORMAL, 4'b0110, "XOR");

        // ALUOp=11 (I-type ALU: ADDI)
        check_alu(2'b11, F3_ADD_SUB, F7_NORMAL, 4'b0000, "ADDI   ADD");

        $display("");
        $display("========================================");
        $display("  DETAILED SIGNAL DUMP");
        $display("========================================");
        $display("--- Main Control ---");
        opcode = R_TYPE; #5; $display("R-TYPE  : RegWrite=%b ALUSrc=%b MemRead=%b MemWrite=%b MemtoReg=%b Branch=%b ALUOp=%b", RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp);
        opcode = I_ALU;  #5; $display("ADDI    : RegWrite=%b ALUSrc=%b MemRead=%b MemWrite=%b MemtoReg=%b Branch=%b ALUOp=%b", RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp);
        opcode = I_LOAD; #5; $display("LOAD    : RegWrite=%b ALUSrc=%b MemRead=%b MemWrite=%b MemtoReg=%b Branch=%b ALUOp=%b", RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp);
        opcode = S_TYPE; #5; $display("STORE   : RegWrite=%b ALUSrc=%b MemRead=%b MemWrite=%b MemtoReg=%b Branch=%b ALUOp=%b", RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp);
        opcode = B_TYPE; #5; $display("BEQ     : RegWrite=%b ALUSrc=%b MemRead=%b MemWrite=%b MemtoReg=%b Branch=%b ALUOp=%b", RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp);

        $display("--- ALU Control ---");
        aluop_in=2'b10; funct3=F3_ADD_SUB; funct7=F7_NORMAL; #5; $display("ADD     : ALUControl=%b (%0d)", ALUControl, ALUControl);
        aluop_in=2'b10; funct3=F3_ADD_SUB; funct7=F7_SUB;    #5; $display("SUB     : ALUControl=%b (%0d)", ALUControl, ALUControl);
        aluop_in=2'b10; funct3=F3_SLL;     funct7=F7_NORMAL; #5; $display("SLL     : ALUControl=%b (%0d)", ALUControl, ALUControl);
        aluop_in=2'b10; funct3=F3_SRL;     funct7=F7_NORMAL; #5; $display("SRL     : ALUControl=%b (%0d)", ALUControl, ALUControl);
        aluop_in=2'b10; funct3=F3_AND;     funct7=F7_NORMAL; #5; $display("AND     : ALUControl=%b (%0d)", ALUControl, ALUControl);
        aluop_in=2'b10; funct3=F3_OR;      funct7=F7_NORMAL; #5; $display("OR      : ALUControl=%b (%0d)", ALUControl, ALUControl);
        aluop_in=2'b10; funct3=F3_XOR;     funct7=F7_NORMAL; #5; $display("XOR     : ALUControl=%b (%0d)", ALUControl, ALUControl);
        aluop_in=2'b11; funct3=F3_ADD_SUB; funct7=F7_NORMAL; #5; $display("ADDI    : ALUControl=%b (%0d)", ALUControl, ALUControl);
        aluop_in=2'b00; funct3=F3_LW;      funct7=F7_NORMAL; #5; $display("LW/SW   : ALUControl=%b (%0d)", ALUControl, ALUControl);
        aluop_in=2'b01; funct3=F3_BEQ;     funct7=F7_NORMAL; #5; $display("BEQ     : ALUControl=%b (%0d)", ALUControl, ALUControl);

        $display("");
        $display("========================================");
        $display("  RESULTS: %0d PASSED  |  %0d FAILED", pass_count, fail_count);
        $display("========================================");
        $finish;
    end

endmodule