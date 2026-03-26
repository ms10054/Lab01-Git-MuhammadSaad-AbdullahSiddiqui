`timescale 1ns / 1ps

module topModule (
    input        clk,
    input        rst,
    input  [3:0] sw,
    input  [3:0] btns,
    output [15:0] leds
);

    // Debouncer  -  debouncer(clk, pbin, pbout)
    wire reset_debounced;
    debouncer debouncer_inst (
        .clk  (clk),
        .pbin (btns[0]),
        .pbout(reset_debounced)
    );
    wire system_reset = rst | reset_debounced;

    // FSM  -  fsm(clk, rst, sw_in, led_out, ALUControl, cnt_en)
    wire [3:0] display_leds;
    wire [3:0] ALUControl;
    wire       cnt_en;

    fsm fsm_inst (
        .clk       (clk),
        .rst       (system_reset),
        .sw_in     (sw),
        .led_out   (display_leds),
        .ALUControl(ALUControl),
        .cnt_en    (cnt_en)
    );

    // RegisterFile  -  RegisterFile(clk, rst, WriteEnable,
    //                   rs1, rs2, rd, WriteData, ReadData1, ReadData2)
    reg        rf_we;
    reg [4:0]  rf_rs1, rf_rs2, rf_rd;
    reg [31:0] rf_wd;
    wire [31:0] rf_rd1, rf_rd2;

    RegisterFile rf_inst (
        .clk        (clk),
        .rst        (system_reset),
        .WriteEnable(rf_we),
        .rs1        (rf_rs1),
        .rs2        (rf_rs2),
        .rd         (rf_rd),
        .WriteData  (rf_wd),
        .ReadData1  (rf_rd1),
        .ReadData2  (rf_rd2)
    );

    // RF write-sequence: loads CONST_A->x1, CONST_B->x2 at startup
    localparam [31:0] CONST_A = 32'h10101010;
    localparam [31:0] CONST_B = 32'h01010101;
    localparam [1:0] RF_IDLE=2'd0, RF_WX1=2'd1, RF_WX2=2'd2, RF_RUN=2'd3;

    reg [1:0]  rf_state;
    reg [26:0] rf_div;
    reg        rf_tick;

    always @(posedge clk or posedge system_reset) begin
        if (system_reset) begin rf_div<=0; rf_tick<=0; end
        else if (rf_div==27'd49_999_999) begin rf_div<=0; rf_tick<=~rf_tick; end
        else rf_div <= rf_div + 1;
    end

    always @(posedge rf_tick or posedge system_reset) begin
        if (system_reset) begin
            rf_state<=RF_IDLE; rf_we<=0;
            rf_rs1<=0; rf_rs2<=0; rf_rd<=0; rf_wd<=0;
        end else case (rf_state)
            RF_IDLE: begin rf_we<=1; rf_rd<=5'd1; rf_wd<=CONST_A; rf_state<=RF_WX1; end
            RF_WX1:  begin rf_we<=1; rf_rd<=5'd2; rf_wd<=CONST_B; rf_state<=RF_WX2; end
            RF_WX2:  begin rf_we<=0; rf_rs1<=5'd1; rf_rs2<=5'd2;  rf_state<=RF_RUN; end
            RF_RUN:  begin rf_we<=0; rf_rs1<=5'd1; rf_rs2<=5'd2; end
            default: rf_state<=RF_IDLE;
        endcase
    end

    // ALU_32Bit  -  ALU_32Bit(A, B, ALUControl, carry_flag, ALUResult, Zero)
    wire        carry_flag;
    wire        zero_flag;
    wire [31:0] ALUResult;

    ALU_32Bit alu_inst (
        .A         (rf_rd1),
        .B         (rf_rd2),
        .ALUControl(ALUControl),
        .carry_flag(carry_flag),
        .ALUResult (ALUResult),
        .Zero      (zero_flag)
    );

    // leds peripheral  -  leds(clk, rst, writeData, writeEnable,
    //                       readEnable, memAddress, readData, leds)
    wire [31:0] led_readData;
    wire [15:0] led_output;

    leds leds_inst (
        .clk        (clk),
        .rst        (system_reset),
        .writeData  (ALUResult),
        .writeEnable(cnt_en),
        .readEnable (1'b0),
        .memAddress (30'd0),
        .readData   (led_readData),
        .leds       (led_output)
    );

    // switches  -  switches(clk, rst, btns, writeData, writeEnable,
    //               readEnable, memAddress, switches, readData)
    wire [31:0] sw_readData;

    switches switches_inst (
        .clk        (clk),
        .rst        (system_reset),
        .btns       ({12'd0, btns}),
        .writeData  (32'd0),
        .writeEnable(1'b0),
        .readEnable (1'b1),
        .memAddress (30'd0),
        .switches   ({12'd0, sw}),
        .readData   (sw_readData)
    );

    assign leds = led_output;

endmodule