`timescale 1ns / 1ps

module led (
    input             clk,
    input             rst,
    input      [31:0] dataIn,
    output reg [31:0] dataOut
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            dataOut <= 32'd0;
        else
            dataOut <= dataIn;
    end

endmodule