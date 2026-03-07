`timescale 1ns / 1ps

module leds (
    input             clk,
    input             rst,
    input      [31:0] writeData,    // 32-bit data to display on LEDs
    input             writeEnable,  // Assert to write to LED register
    input             readEnable,   // Unused (LEDs are write-only)
    input      [29:0] memAddress,   // Peripheral memory address
    output reg [31:0] readData,     // Always 0 (not readable)
    output reg [15:0] leds          // 16-bit LED output
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            leds     <= 16'd0;
            readData <= 32'd0;
        end else begin
            readData <= 32'd0;  // LEDs cannot be read back
            if (writeEnable)
                leds <= writeData[15:0];  // Latch lower 16 bits to LEDs
        end
    end

endmodule