`timescale 1ns / 1ps

module DataMemory (
    input             clk,
    input             MemWrite,     // write enable (from address decoder)
    input             MemRead,      // read  enable (from address decoder)
    input      [7:0]  address,      // local word address (address[7:0])
    input      [31:0] write_data,
    output reg [31:0] read_data
);

    reg [31:0] mem [0:511];

    // Synchronous write
    always @(posedge clk) begin
        if (MemWrite)
            mem[address] <= write_data;
    end

    // Asynchronous read
    always @(*) begin
        if (MemRead)
            read_data = mem[address];
        else
            read_data = 32'd0;
    end

endmodule