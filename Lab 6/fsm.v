`timescale 1ns / 1ps

module fsm (
    input             clk,        // 100 MHz system clock
    input             rst,        // Active-high reset
    input      [3:0]  sw_in,      // Switch input: selects ALU operation
    output reg [3:0]  led_out,    // LED output mirrors ALU control in ACTIVE state
    output reg [3:0]  ALUControl, // ALU operation control forwarded to ALU_32Bit
    output reg        cnt_en      // Enable signal: 1 when FSM is in ACTIVE state
);

    // ── State encoding ────────────────────────────────────────
    localparam IDLE   = 1'b0,
               ACTIVE = 1'b1;

    reg current_state;

    // ── Clock divider (~1 Hz from 100 MHz) ───────────────────
    // Divides 100 MHz by 100,000,000 → toggles every 0.5 s → 1 Hz
    reg [26:0] divider_count;
    reg        divided_clk;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            divider_count <= 27'd0;
            divided_clk   <= 1'b0;
        end else begin
            if (divider_count == 27'd49_999_999) begin
                divider_count <= 27'd0;
                divided_clk   <= ~divided_clk;  // Toggle: period = 1 s
            end else begin
                divider_count <= divider_count + 1;
            end
        end
    end

    // ── FSM: state register + output logic ───────────────────
    always @(posedge divided_clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            led_out       <= 4'd0;
            ALUControl    <= 4'd0;
            cnt_en        <= 1'b0;
        end else begin
            case (current_state)

                // ── IDLE: wait for non-zero switch input ──────
                IDLE: begin
                    cnt_en  <= 1'b0;
                    led_out <= 4'd0;

                    if (sw_in != 4'd0) begin
                        ALUControl    <= sw_in;    // Latch the selected operation
                        led_out       <= sw_in;    // Show selection on LEDs
                        current_state <= ACTIVE;
                    end
                end

                // ── ACTIVE: run ALU with current switch value ─
                ACTIVE: begin
                    cnt_en     <= 1'b1;
                    ALUControl <= sw_in;           // Track switch changes live
                    led_out    <= sw_in;

                    if (sw_in == 4'd0) begin
                        // Return to IDLE when switches are cleared
                        cnt_en        <= 1'b0;
                        led_out       <= 4'd0;
                        current_state <= IDLE;
                    end
                end

                default: current_state <= IDLE;   // Safety fallback
            endcase
        end
    end

endmodule