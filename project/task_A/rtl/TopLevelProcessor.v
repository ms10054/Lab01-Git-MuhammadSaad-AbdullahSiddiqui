`timescale 1ns / 1ps

module TopLevelProcessor (
    input  wire        clk,
    input  wire        rst,
    input  wire        btn_rst,
    input  wire [15:0] sw,
    output wire [31:0] output_value
);


    reg [26:0] slow_counter = 0;
    reg slow_clk = 0;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            slow_counter <= 0;
            slow_clk <= 0;
        end else begin
            if (slow_counter == 27'd5) begin  // use 27'd15_000_000 for fpga demo
                slow_counter <= 0;
                slow_clk <= ~slow_clk;
            end else begin
                slow_counter <= slow_counter + 1;
            end
        end
end

    // =========================================================
    // WIRES
    // =========================================================
    wire [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4;
    wire [31:0] branch_target;

    wire [31:0] instruction;

    wire [6:0] opcode;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = instruction[6:0];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    wire [31:0] imm_ext;

    wire regWrite;
    wire memRead;
    wire memWrite_ctrl;
    wire aluSrc;
    wire memToReg;
    wire branch;
    wire jal;
    wire [1:0] aluOp;

    wire [3:0] aluControl;

    wire [31:0] readData1;
    wire [31:0] readData2;

    wire [31:0] alu_b;
    wire [31:0] alu_result;
    wire carry_flag;
    wire zero_flag;

    wire [31:0] mem_readData;
    wire [31:0] wb_data;

    // =========================================================
    // PROGRAM COUNTER
    // =========================================================
    ProgramCounter pc_inst (
        .clk    (slow_clk),
        .reset  (rst),
        .pc_next(pc_next),
        .pc     (pc)
    );

    pcAdder pc_adder_inst (
        .pc      (pc),
        .pc_plus4(pc_plus4)
    );

    instructionMemory imem_inst (
        .instAddress(pc),
        .instruction(instruction)
    );

    immGen imm_gen_inst (
        .instruction(instruction),
        .imm_out    (imm_ext)
    );

    // =========================================================
    // CONTROL UNIT
    // =========================================================
    MainControl main_ctrl_inst (
        .opcode   (opcode),
        .regWrite (regWrite),
        .memRead  (memRead),
        .memWrite (memWrite_ctrl),
        .aluSrc   (aluSrc),
        .memToReg (memToReg),
        .branch   (branch),
        .jal      (jal),
        .aluOp    (aluOp)
    );

    ALUControl alu_ctrl_inst (
        .aluOp           (aluOp),
        .funct3          (funct3),
        .funct7          (funct7),
        .aluControlSignal(aluControl)
    );

    // =========================================================
    // REGISTER FILE
    // =========================================================
    RegisterFile reg_file_inst (
        .clk        (slow_clk),
        .rst        (rst),
        .WriteEnable(regWrite),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .WriteData  (wb_data),
        .ReadData1  (readData1),
        .ReadData2  (readData2)
    );

    mux2 alu_src_mux (
        .in0(readData2),
        .in1(imm_ext),
        .sel(aluSrc),
        .out(alu_b)
    );

    // =========================================================
    // ALU
    // Your ALU mapping:
    // AND = 0000
    // OR  = 0001
    // XOR = 0010
    // SLL = 0100
    // SRL = 0101
    // ADD = 0110
    // SUB = 0111
    // =========================================================
    ALU_32Bit alu_inst (
        .A         (readData1),
        .B         (alu_b),
        .ALUControl(aluControl),
        .carry_flag(carry_flag),
        .ALUResult (alu_result),
        .Zero      (zero_flag)
    );

    // =========================================================
    // BRANCH / JUMP LOGIC
    // =========================================================
    wire is_beq;
    wire is_jalr;
    
    assign is_beq  = branch & (funct3 == 3'b000);
    assign is_jalr = (opcode == 7'b1100111);

    wire [31:0] jalr_target;
    wire [31:0] pc_target;

    assign jalr_target = {alu_result[31:1], 1'b0};
    assign pc_target   = is_jalr ? jalr_target : branch_target;

    wire pcsrc;

    assign pcsrc = (is_beq & zero_flag) |
                   jal |
                   is_jalr;

    branchAdder branch_adder_inst (
        .pc           (pc),
        .imm          (imm_ext),
        .branch_target(branch_target)
    );

    mux2 pc_mux_inst (
        .in0(pc_plus4),
        .in1(pc_target),
        .sel(pcsrc),
        .out(pc_next)
    );

    // =========================================================
    // ADDRESS DECODER / DATA MEMORY / MMIO
    //
    // 0x200 = 32-bit output register
    // 0x300 = switches input
    // 0x350 = btn_rst input
    // =========================================================
    addressDecoderTop addr_decoder_inst (
        .clk         (slow_clk),
        .rst         (rst),
        .address     (alu_result),
        .readEnable  (memRead),
        .writeEnable (memWrite_ctrl),
        .writeData   (readData2),
        .switches    (sw),
        .btn_rst     (btn_rst),
        .readData    (mem_readData),
        .output_value(output_value)
    );

    // =========================================================
    // WRITE BACK
    // =========================================================
    wire [31:0] alu_or_mem;

    assign alu_or_mem = memToReg ? mem_readData : alu_result;

    // JAL/JALR write PC + 4 into rd
    assign wb_data = (jal | is_jalr) ? pc_plus4 : alu_or_mem;

endmodule