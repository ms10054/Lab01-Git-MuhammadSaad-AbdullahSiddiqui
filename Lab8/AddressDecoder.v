`timescale 1ns / 1ps

module AddressDecoder (
    input  [9:0] address,
    output       DataMem,
    output       LEDWrite,
    output       SwitchReadEnable
);

    wire [1:0] sel = address[9:8];

    assign DataMem          = (sel == 2'b00);
    assign LEDWrite         = (sel == 2'b01);
    assign SwitchReadEnable = (sel == 2'b10);

endmodule