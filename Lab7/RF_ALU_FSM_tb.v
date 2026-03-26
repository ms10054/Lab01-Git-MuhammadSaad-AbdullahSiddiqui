`timescale 1ns / 1ps

module RF_ALU_FSM_tb;

    // ---- Clock / Reset ----
    reg clk, rst;
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- RegisterFile wires ----
    reg         rf_WriteEnable;
    reg  [4:0]  rf_rs1, rf_rs2, rf_rd;
    reg  [31:0] rf_WriteData;
    wire [31:0] rf_ReadData1, rf_ReadData2;

    RegisterFile rf (
        .clk        (clk),
        .rst        (rst),
        .WriteEnable(rf_WriteEnable),
        .rs1        (rf_rs1),
        .rs2        (rf_rs2),
        .rd         (rf_rd),
        .WriteData  (rf_WriteData),
        .ReadData1  (rf_ReadData1),
        .ReadData2  (rf_ReadData2)
    );

    // ---- ALU_32Bit wires ----
    // FIX 1: port names match ALU_32bits.v exactly
    reg  [3:0]  alu_control;
    wire [31:0] alu_result;
    wire        alu_carry;
    wire        alu_zero;

    ALU_32Bit alu (
        .A         (rf_ReadData1),
        .B         (rf_ReadData2),
        .ALUControl   (alu_control),   // was .ALUControl
        .carry_flag(alu_carry),     // was .carry_flag
        .ALUResult    (alu_result),    // was .ALUResult
        .Zero      (alu_zero)
    );

    // ================================================================
    //  FSM state encoding
    // ================================================================
    localparam [2:0]
        IDLE            = 3'd0,
        WRITE_REGS      = 3'd1,
        READ_REGISTERS  = 3'd2,
        ALU_OPERATION   = 3'd3,
        WRITE_REGISTERS = 3'd4,
        DONE            = 3'd5;

    reg [2:0] state;

    // ---- ALU control codes ----
    localparam [3:0]
        OP_AND = 4'b0000,
        OP_OR  = 4'b0001,
        OP_XOR = 4'b0010,
        OP_SLL = 4'b0100,
        OP_SRL = 4'b0101,
        OP_ADD = 4'b0110,
        OP_SUB = 4'b0111;

    localparam TOTAL_OPS = 9;
    reg [3:0] op_idx;
    reg [1:0] init_idx;

    // FIX 2: removed alu_result_latch - latch happens in WRITE_REGISTERS
    // so alu_control has already propagated through the combinational ALU
    reg        alu_zero_latch;

    // ---- Assert helper ----
    task check;
        input [31:0]   got;
        input [31:0]   expected;
        input [8*40:1] label;
        begin
            if (got === expected)
                $display("PASS  [%0t ns]  %0s  =0x%08X", $time, label, got);
            else
                $display("FAIL  [%0t ns]  %0s  got=0x%08X  exp=0x%08X",
                         $time, label, got, expected);
        end
    endtask

    // ================================================================
    //  FSM
    // ================================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state          <= IDLE;
            op_idx         <= 0;
            init_idx       <= 0;
            rf_WriteEnable <= 0;
            rf_rd          <= 0;
            rf_rs1         <= 0;
            rf_rs2         <= 0;
            rf_WriteData   <= 0;
            alu_control    <= 0;
            alu_zero_latch <= 0;
        end else begin
            case (state)

                // ---- IDLE ----
                IDLE: begin
                    rf_WriteEnable <= 0;
                    op_idx         <= 0;
                    init_idx       <= 0;
                    state          <= WRITE_REGS;
                    $display("\n[%0t ns] FSM: IDLE -> WRITE_REGS", $time);
                end

                // ---- WRITE_REGS: load x1=0x10101010, x2=0x01010101, x3=0x00000005 ----
                WRITE_REGS: begin
                    rf_WriteEnable <= 1;
                    case (init_idx)
                        0: begin rf_rd <= 1; rf_WriteData <= 32'h10101010; end
                        1: begin rf_rd <= 2; rf_WriteData <= 32'h01010101; end
                        2: begin rf_rd <= 3; rf_WriteData <= 32'h00000005; end
                    endcase
                    if (init_idx == 2) begin
                        rf_WriteEnable <= 0;
                        state          <= READ_REGISTERS;
                        $display("[%0t ns] FSM: WRITE_REGS -> READ_REGISTERS", $time);
                    end else begin
                        init_idx <= init_idx + 1;
                    end
                end

                // ---- READ_REGISTERS: set rs1/rs2, handle RAW write for op 8 ----
                READ_REGISTERS: begin
                    rf_WriteEnable <= 0;
                    case (op_idx)
                        // RAW test: overwrite x1 then read it
                        8: begin
                            rf_WriteEnable <= 1;
                            rf_rd          <= 1;
                            rf_WriteData   <= 32'hCAFEBABE;
                            rf_rs1         <= 1;
                            rf_rs2         <= 2;
                        end
                        default: begin
                            rf_rs1 <= 1;
                            rf_rs2 <= 2;
                        end
                    endcase
                    state <= ALU_OPERATION;
                    $display("[%0t ns] FSM: READ_REGISTERS -> ALU_OPERATION  op=%0d",
                             $time, op_idx);
                end

                // ---- ALU_OPERATION: set control only; do NOT latch result here ----
                // FIX 2: alu_control is set here (non-blocking → takes effect next cycle)
                // result latching moved to WRITE_REGISTERS where ALU output is stable
                ALU_OPERATION: begin
                    rf_WriteEnable <= 0;
                    case (op_idx)
                        0: alu_control <= OP_ADD;
                        1: alu_control <= OP_SUB;
                        2: alu_control <= OP_AND;
                        3: alu_control <= OP_OR;
                        4: alu_control <= OP_XOR;
                        5: alu_control <= OP_SLL;
                        6: alu_control <= OP_SRL;
                        7: alu_control <= OP_SUB;  // BEQ: x1-x2, check Zero
                        8: alu_control <= OP_ADD;  // RAW: new_x1 + x2
                        default: alu_control <= OP_AND;
                    endcase
                    state <= WRITE_REGISTERS;
                    $display("[%0t ns] FSM: ALU_OPERATION -> WRITE_REGISTERS  op=%0d",
                             $time, op_idx);
                end

                // ---- WRITE_REGISTERS: alu_control now stable → alu_result is valid ----
                WRITE_REGISTERS: begin
                    rf_WriteEnable <= 1;

                    // Latch Zero here where alu_result is already correct
                    alu_zero_latch <= alu_zero;

                    case (op_idx)
                        0: begin rf_rd <= 4;  rf_WriteData <= alu_result; end  // ADD  -> x4
                        1: begin rf_rd <= 5;  rf_WriteData <= alu_result; end  // SUB  -> x5
                        2: begin rf_rd <= 6;  rf_WriteData <= alu_result; end  // AND  -> x6
                        3: begin rf_rd <= 7;  rf_WriteData <= alu_result; end  // OR   -> x7
                        4: begin rf_rd <= 8;  rf_WriteData <= alu_result; end  // XOR  -> x8
                        5: begin rf_rd <= 9;  rf_WriteData <= alu_result; end  // SLL  -> x9
                        6: begin rf_rd <= 10; rf_WriteData <= alu_result; end  // SRL  -> x10
                        7: begin                                                // BEQ flag -> x11
                            rf_rd        <= 11;
                            rf_WriteData <= alu_zero ? 32'd1 : 32'd0;
                        end
                        8: begin rf_rd <= 12; rf_WriteData <= alu_result; end  // RAW  -> x12
                        default: begin rf_rd <= 0; rf_WriteData <= 0; end
                    endcase

                    // Assertions - alu_result is now correct
                    case (op_idx)
                        0: check(alu_result, 32'h11111111, "ADD  x1+x2        ");
                        1: check(alu_result, 32'h0F0F0F0F, "SUB  x1-x2        ");
                        2: check(alu_result, 32'h00000000, "AND  x1&x2        ");
                        3: check(alu_result, 32'h11111111, "OR   x1|x2        ");
                        4: check(alu_result, 32'h11111111, "XOR  x1^x2        ");
                        5: check(alu_result, 32'h20202020, "SLL  x1<<1        ");
                        6: check(alu_result, 32'h08080808, "SRL  x1>>1        ");
                        7: check(alu_zero,   1'b0,         "BEQ  x1!=x2 Zero=0");
                        8: check(alu_result, 32'hCBFFBBBF, "RAW  newx1+x2     ");
                    endcase

                    $display("[%0t ns] FSM: WRITE_REGISTERS  rd=x%0d  data=0x%08X  Zero=%0b",
                             $time, rf_rd, alu_result, alu_zero);

                    if (op_idx == TOTAL_OPS - 1) begin
                        rf_WriteEnable <= 0;
                        state          <= DONE;
                        $display("[%0t ns] FSM: -> DONE", $time);
                    end else begin
                        op_idx <= op_idx + 1;
                        state  <= READ_REGISTERS;
                    end
                end

                // ---- DONE ----
                DONE: begin
                    rf_WriteEnable <= 0;
                end

                default: state <= IDLE;
            endcase
        end
    end

    // ================================================================
    //  Stimulus + final readback checks
    // ================================================================
    initial begin
        $dumpfile("RF_ALU_FSM_tb.vcd");
        $dumpvars(0, RF_ALU_FSM_tb);
        $display("=== RF_ALU_FSM Integrated Testbench Start ===");

        rst = 1;
        repeat(2) @(posedge clk); #1;
        rst = 0;

        // Wait for FSM to reach DONE (60 cycles is plenty)
        repeat(60) @(posedge clk); #1;

        // ---- Final register-file readback ----
        $display("\n--- Final register file readback ---");
        @(negedge clk);
        rf_rs1 = 4;  rf_rs2 = 5;  #1;
        check(rf_ReadData1, 32'h11111111, "Readback x4  ADD result");
        check(rf_ReadData2, 32'h0F0F0F0F, "Readback x5  SUB result");

        rf_rs1 = 6;  rf_rs2 = 7;  #1;
        check(rf_ReadData1, 32'h00000000, "Readback x6  AND result");
        check(rf_ReadData2, 32'h11111111, "Readback x7  OR  result");

        rf_rs1 = 8;  rf_rs2 = 9;  #1;
        check(rf_ReadData1, 32'h11111111, "Readback x8  XOR result");
        check(rf_ReadData2, 32'h20202020, "Readback x9  SLL result");

        rf_rs1 = 10; rf_rs2 = 11; #1;
        check(rf_ReadData1, 32'h08080808, "Readback x10 SRL result");
        check(rf_ReadData2, 32'h00000000, "Readback x11 BEQ flag  ");

        rf_rs1 = 12; #1;
        check(rf_ReadData1, 32'hCBFFBBBF, "Readback x12 RAW result");

        rf_rs1 = 0;  #1;
        check(rf_ReadData1, 32'h00000000, "Readback x0  always 0  ");

        $display("\n=== RF_ALU_FSM Integrated Testbench Complete ===");
        $finish;
    end

endmodule