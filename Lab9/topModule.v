`timescale 1ns / 1ps

module topModule (
    input  wire        clk,       // 100 MHz
    input  wire        rst_btn,   // BTNC - reset
    input  wire        next_btn,  // BTNU - advance FSM
    input  wire [15:0] sw_pins,   // 16 slide switches
    input  wire [15:0] btn_pins,  // remaining buttons (BTNL/BTNR etc.) - tie 0 if unused
    output wire [15:0] led_pins   // 16 LEDs
);

    // -------------------------------------------------------
    // 1. Debounce reset and next buttons (Lab 5 module)
    // -------------------------------------------------------
    wire rst_clean;
    wire next_clean;

    debouncer u_dbnc_rst (
        .clk   (clk),
        .pbin  (rst_btn),
        .pbout (rst_clean)
    );

    debouncer u_dbnc_next (
        .clk   (clk),
        .pbin  (next_btn),
        .pbout (next_clean)
    );

    // Rising-edge pulse on next_clean - one-cycle pulse per button press
    reg  next_d;
    wire next_pulse;
    always @(posedge clk or posedge rst_clean) begin
        if (rst_clean) next_d <= 1'b0;
        else           next_d <= next_clean;
    end
    assign next_pulse = next_clean & ~next_d;

    // -------------------------------------------------------
    // 2. Read switches via Lab 5 switches module
    //    We tie writeData/writeEnable/memAddress to 0 (read-only use).
    //    readEnable=1 always so sw_data updates every cycle.
    // -------------------------------------------------------
    wire [31:0] sw_data;   // [31:16] = btns, [15:0] = sw

    switches u_sw (
        .clk        (clk),
        .rst        (rst_clean),
        .btns       (btn_pins),
        .writeData  (32'd0),
        .writeEnable(1'b0),
        .readEnable (1'b1),
        .memAddress (30'd0),
        .sw         (sw_pins),
        .readData   (sw_data)
    );

    // Unpack switch fields from sw_data[15:0]
    wire [15:0] sw       = sw_data[15:0];
    wire        man_mode = sw[15];   // SW15: 1=manual, 0=FSM
    wire [6:0]  sw_opc   = sw[6:0];
    wire [2:0]  sw_f3    = sw[9:7];
    wire [6:0]  sw_f7    = {sw[14:10], 2'b00}; // 5 bits ? bits[6:2], pad lower 2

    // -------------------------------------------------------
    // 3. FSM - 15 states, one per supported instruction
    //    0:ADD  1:SUB  2:SLL  3:SRL  4:AND  5:OR   6:XOR
    //    7:ADDI 8:LW   9:LH  10:LB  11:SW  12:SH  13:SB  14:BEQ
    // -------------------------------------------------------
    localparam NUM_INST = 4'd14;   // last valid index

    reg [3:0] fsm_state;

    // Instruction ROM: {opcode[6:0], funct3[2:0], funct7[6:0]} = 17 bits
    reg [16:0] instr_rom [0:14];

    initial begin
        instr_rom[ 0] = {7'b0110011, 3'b000, 7'b0000000}; // ADD
        instr_rom[ 1] = {7'b0110011, 3'b000, 7'b0100000}; // SUB
        instr_rom[ 2] = {7'b0110011, 3'b001, 7'b0000000}; // SLL
        instr_rom[ 3] = {7'b0110011, 3'b101, 7'b0000000}; // SRL
        instr_rom[ 4] = {7'b0110011, 3'b111, 7'b0000000}; // AND
        instr_rom[ 5] = {7'b0110011, 3'b110, 7'b0000000}; // OR
        instr_rom[ 6] = {7'b0110011, 3'b100, 7'b0000000}; // XOR
        instr_rom[ 7] = {7'b0010011, 3'b000, 7'b0000000}; // ADDI
        instr_rom[ 8] = {7'b0000011, 3'b010, 7'b0000000}; // LW
        instr_rom[ 9] = {7'b0000011, 3'b001, 7'b0000000}; // LH
        instr_rom[10] = {7'b0000011, 3'b000, 7'b0000000}; // LB
        instr_rom[11] = {7'b0100011, 3'b010, 7'b0000000}; // SW_INSTR
        instr_rom[12] = {7'b0100011, 3'b001, 7'b0000000}; // SH
        instr_rom[13] = {7'b0100011, 3'b000, 7'b0000000}; // SB
        instr_rom[14] = {7'b1100011, 3'b000, 7'b0000000}; // BEQ
    end

    always @(posedge clk or posedge rst_clean) begin
        if (rst_clean)
            fsm_state <= 4'd0;
        else if (next_pulse)
            fsm_state <= (fsm_state == NUM_INST) ? 4'd0 : fsm_state + 1;
    end

    // -------------------------------------------------------
    // 4. Select source: FSM or manual switches
    // -------------------------------------------------------
    wire [16:0] rom_entry = instr_rom[fsm_state];
    wire [6:0]  fsm_opc   = rom_entry[16:10];
    wire [2:0]  fsm_f3    = rom_entry[9:7];
    wire [6:0]  fsm_f7    = rom_entry[6:0];

    wire [6:0]  opcode    = man_mode ? sw_opc : fsm_opc;
    wire [2:0]  funct3    = man_mode ? sw_f3  : fsm_f3;
    wire [6:0]  funct7    = man_mode ? sw_f7  : fsm_f7;

    // -------------------------------------------------------
    // 5. MainControl
    // -------------------------------------------------------
    wire        RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0]  ALUOp;

    MainControl u_main (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUSrc   (ALUSrc),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .MemtoReg (MemtoReg),
        .Branch   (Branch),
        .ALUOp    (ALUOp)
    );

    // -------------------------------------------------------
    // 6. ALUControl
    // -------------------------------------------------------
    wire [3:0] ALUControl;

    ALUControl u_alu (
        .ALUOp     (ALUOp),
        .funct3    (funct3),
        .funct7    (funct7),
        .ALUControl(ALUControl)
    );

    // -------------------------------------------------------
    // 7. Drive LEDs via Lab 5 leds module
    //    Pack all control signals into writeData[15:0] and
    //    assert writeEnable every cycle so LEDs track instantly.
    // -------------------------------------------------------
    wire [15:0] led_word;
    assign led_word[0]    = RegWrite;
    assign led_word[1]    = ALUSrc;
    assign led_word[2]    = MemRead;
    assign led_word[3]    = MemWrite;
    assign led_word[4]    = MemtoReg;
    assign led_word[5]    = Branch;
    assign led_word[7:6]  = ALUOp;
    assign led_word[11:8] = ALUControl;
    assign led_word[15:12]= fsm_state;

    wire [31:0] led_readData_nc; // not used

    leds u_leds (
        .clk        (clk),
        .rst        (rst_clean),
        .writeData  ({16'd0, led_word}),
        .writeEnable(1'b1),            // always write ? LEDs always updated
        .readEnable (1'b0),
        .memAddress (30'd0),
        .readData   (led_readData_nc),
        .leds       (led_pins)
    );

endmodule