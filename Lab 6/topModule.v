`timescale 1ns / 1ps

module topModule (
    input         clk,          // 100 MHz system clock
    input         rst,          // Global reset (active high)
    input  [3:0]  sw,           // 4-bit switch: selects ALU operation
    input  [15:0] btns,         // 16-bit buttons; btns[0] = debounced reset
    output [15:0] leds_out      // 16-bit LED output (ALUResult[15:0])
);

    // ── Hardcoded ALU Operands ────────────────────────────────
    wire [31:0] A = 32'h10101010;
    wire [31:0] B = 32'h01010101;

    // ── Debouncer ─────────────────────────────────────────────
    // Filters 10 ms of mechanical bounce from btns[0]
    wire reset_debounced;
    debouncer debouncer_inst (
        .clk  (clk),
        .pbin (btns[0]),
        .pbout(reset_debounced)
    );

    // Combine slide-switch reset and debounced button reset
    wire system_reset = rst | reset_debounced;

    // ── FSM ───────────────────────────────────────────────────
    wire [3:0] display_leds;    // LED output from FSM (mirrors ALUControl)
    wire [3:0] ALUControl;      // ALU operation selector driven by FSM
    wire       cnt_en;          // ALU enable (1 when FSM is ACTIVE)

    fsm fsm_inst (
        .clk       (clk),
        .rst       (system_reset),
        .sw_in     (sw),
        .led_out   (display_leds),
        .ALUControl(ALUControl),
        .cnt_en    (cnt_en)
    );

    // ── 32-Bit ALU ────────────────────────────────────────────
    wire        carry_flag;     // Carry-out / shift-out from MSB
    wire        zero_flag;      // High when ALUResult == 0
    wire [31:0] ALUResult;      // 32-bit operation result

    ALU_32Bit alu_inst (
        .A         (A),
        .B         (B),
        .ALUControl(ALUControl),
        .carry_flag(carry_flag),
        .ALUResult (ALUResult),
        .Zero      (zero_flag)
    );

    // ── LED Peripheral ────────────────────────────────────────
    // Writes ALUResult to the 16-bit LED output register.
    wire [31:0] led_readData;   // Unused (LEDs are write-only)
    wire [15:0] led_output;     // 16-bit registered LED output

    leds leds_inst (
        .clk        (clk),
        .rst        (system_reset),
        .writeData  (ALUResult),    // Feed ALU result to LED peripheral
        .writeEnable(cnt_en),       // Only write when FSM is active
        .readEnable (1'b0),         // LEDs are write-only
        .memAddress (30'd0),
        .readData   (led_readData),
        .leds       (led_output)
    );

    // ── Switch Peripheral ─────────────────────────────────────
    // Provides memory-mapped read access to switches and buttons.
    wire [31:0] sw_readData;    // {btns, switches} packed as 32-bit word

    switches switches_inst (
        .clk        (clk),
        .rst        (system_reset),
        .btns       (btns),         // All 16 buttons forwarded
        .writeData  (32'd0),        // Unused (read-only peripheral)
        .writeEnable(1'b0),         // Unused
        .readEnable (1'b1),         // Always sample switch state
        .memAddress (30'd0),
        .switches   ({12'd0, sw}),  // Map 4-bit sw into lower 4 bits
        .readData   (sw_readData)
    );

    // ── Board LED Output ──────────────────────────────────────
    assign leds_out = led_output;

endmodule