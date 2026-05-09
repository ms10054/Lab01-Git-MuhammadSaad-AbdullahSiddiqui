`timescale 1ns / 1ps

module AddressDecoder (
    input  wire [31:0] address,
    output wire        DataMem,
    output wire        OutputWrite,
    output wire        SwitchReadEnable,
    output wire        ButtonReadEnable
);

    // 256 words RAM = 1024 bytes
    // RAM address range: 0x000 to 0x3FF
    assign DataMem = (address < 32'h00000400);

    // 0x200 is also FPGA output register on write
    assign OutputWrite = (address == 32'h00000200);

    // memory-mapped inputs
    assign SwitchReadEnable = (address == 32'h00000300);
    assign ButtonReadEnable = (address == 32'h00000350);

endmodule