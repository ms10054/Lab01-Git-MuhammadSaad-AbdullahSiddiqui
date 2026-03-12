`timescale 1ns / 1ps

module AddressDecoder (
    input      [9:8]  address,      // top 2 bits of 10-bit address
    input             readEnable,   // global read  request from CPU
    input             writeEnable,  // global write request from CPU

    output reg        DataMemWrite,
    output reg        DataMemRead,
    output reg        LEDWrite,
    output reg        SwitchReadEnable
);

    always @(*) begin
        // safe defaults
        DataMemWrite     = 1'b0;
        DataMemRead      = 1'b0;
        LEDWrite         = 1'b0;
        SwitchReadEnable = 1'b0;

        case (address)
            2'b00: begin   // Data Memory
                DataMemWrite = writeEnable;
                DataMemRead  = readEnable;
            end
            2'b01: begin   // LEDs (write-only)
                LEDWrite = writeEnable;
            end
            2'b10: begin   // Switches (read-only)
                SwitchReadEnable = readEnable;
            end
            default: ;     // 2'b11 unused - all signals stay 0
        endcase
    end

endmodule