`timescale 1ns / 1ps

module addressDecoderTop (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] address,
    input  wire        readEnable,
    input  wire        writeEnable,
    input  wire [31:0] writeData,
    input  wire [15:0] switches,
    input  wire        btn_rst,
    output reg  [31:0] readData,
    output reg  [31:0] output_value
);

    wire [31:0] ram_readData;

    wire DataMem;
    wire OutputWrite;
    wire SwitchReadEnable;
    wire ButtonReadEnable;

    AddressDecoder decoder_inst (
        .address         (address),
        .DataMem         (DataMem),
        .OutputWrite     (OutputWrite),
        .SwitchReadEnable(SwitchReadEnable),
        .ButtonReadEnable(ButtonReadEnable)
    );

    // DataMemory is enabled for all RAM addresses, including 0x200.
    DataMemory ram_inst (
        .clk      (clk),
        .rst      (rst),
        .MemRead  (readEnable && DataMem),
        .MemWrite (writeEnable && DataMem),
        .address  (address),
        .WriteData(writeData),
        .ReadData (ram_readData)
    );

    // Output register also updates when writing to 0x200.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            output_value <= 32'b0;
        end else begin
            if (writeEnable && OutputWrite) begin
                output_value <= writeData;
            end
        end
    end

    // Read mux
    // Switch/button reads get priority over RAM reads because
    // 0x300 and 0x350 are inside the broad 0x000-0x3FF RAM range.
    always @(*) begin
        if (readEnable) begin
            if (SwitchReadEnable) begin
                readData = {16'b0, switches};
            end else if (ButtonReadEnable) begin
                readData = {31'b0, btn_rst};
            end else if (DataMem) begin
                readData = ram_readData;
            end else begin
                readData = 32'b0;
            end
        end else begin
            readData = 32'b0;
        end
    end

endmodule