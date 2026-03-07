`timescale 1ns / 1ps

module debouncer(
    input  wire clk,    // 100 MHz system clock
    input  wire pbin,   // Raw push-button input (may bounce)
    output reg  pbout   // Debounced push-button output
);

    // ── 20-bit stability counter (max = 1,048,575 > 999,999) ─
    reg [19:0] stability_counter;

    // ── Two-stage synchronizer registers ─────────────────────
    reg btn_sync_stage0;  // First synchronizer flip-flop
    reg btn_sync_stage1;  // Second synchronizer flip-flop (stable, metastability resolved)

    // ── Stage 1 & 2: synchronize input to clock domain ───────
    always @(posedge clk) begin
        btn_sync_stage0 <= pbin;
        btn_sync_stage1 <= btn_sync_stage0;
    end

    // ── Stage 3: debounce logic ───────────────────────────────
    always @(posedge clk) begin
        if (btn_sync_stage1 == pbout) begin
            // Input matches output → no pending change, reset counter
            stability_counter <= 20'd0;
        end else begin
            // Input differs from output → count stable cycles
            stability_counter <= stability_counter + 1'b1;

            if (stability_counter == 20'd999_999) begin
                // Input has been stable for 10 ms → accept the new value
                pbout             <= btn_sync_stage1;
                stability_counter <= 20'd0;
            end
        end
    end

endmodule