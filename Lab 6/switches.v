`timescale 1ns / 1ps

module switches (
    input             clk,
    input             rst,
    input      [15:0] btns,         // 16-bit push-button inputs
    input      [31:0] writeData,    // Unused (read-only peripheral)
    input             writeEnable,  // Unused (read-only peripheral)
    input             readEnable,   // Assert to sample switch state
    input      [29:0] memAddress,   // Peripheral memory address
    input      [15:0] switches,     // 16-bit physical switch inputs
    output reg [31:0] readData      // {btns[15:0], switches[15:0]}
);

    // Internal storage: 4 bytes for switch data
    reg [7:0] switchData [3:0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            readData       <= 32'd0;
            switchData[0]  <= 8'd0;
            switchData[1]  <= 8'd0;
            switchData[2]  <= 8'd0;
            switchData[3]  <= 8'd0;
        end else if (readEnable) begin
            // Pack switches into byte array for bus access
            switchData[0] <= switches[7:0];
            switchData[1] <= switches[15:8];
            switchData[2] <= btns[7:0];
            switchData[3] <= btns[15:8];

            // Return {btns, switches} as a 32-bit word
            readData <= {btns, switches};
        end else begin
            readData <= 32'd0;
        end
    end

endmodule