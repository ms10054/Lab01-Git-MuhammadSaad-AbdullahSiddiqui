`timescale 1ns / 1ps

module addressDecoderTop (
    input         clk,
    input         rst,
    input  [31:0] address,
    input         readEnable,
    input         writeEnable,
    input  [31:0] writeData,
    input  [15:0] switches,
    output [31:0] readData,
    output [15:0] leds
);

    // --------------------------------------------------------
    //  Address Decoder
    // --------------------------------------------------------
    wire DataMemWrite, DataMemRead;
    wire LEDWrite, SwitchReadEnable;

    AddressDecoder decoder (
        .address         (address[9:8]),
        .readEnable      (readEnable),
        .writeEnable     (writeEnable),
        .DataMemWrite    (DataMemWrite),
        .DataMemRead     (DataMemRead),
        .LEDWrite        (LEDWrite),
        .SwitchReadEnable(SwitchReadEnable)
    );

    // --------------------------------------------------------
    //  Data Memory
    // --------------------------------------------------------
    wire [31:0] mem_readData;

    DataMemory data_mem (
        .clk        (clk),
        .MemWrite   (DataMemWrite),
        .MemRead    (DataMemRead),
        .address    (address[7:0]),
        .write_data (writeData),
        .read_data  (mem_readData)
    );


    wire [31:0] led_readData;  // always 0 (LEDs are write-only)
    wire [15:0] led_out;

    leds leds_inst (
        .clk        (clk),
        .rst        (rst),
        .writeData  (writeData),
        .writeEnable(LEDWrite),
        .readEnable (1'b0),
        .memAddress (address[29:0]),
        .readData   (led_readData),
        .leds       (led_out)
    );

    // --------------------------------------------------------
    //  Switch peripheral (from Lab 5)
    // --------------------------------------------------------
    wire [31:0] sw_readData;

    switches switches_inst (
        .clk        (clk),
        .rst        (rst),
        .btns       (16'd0),
        .writeData  (32'd0),
        .writeEnable(1'b0),
        .readEnable (SwitchReadEnable),
        .memAddress (address[29:0]),
        .switches   (switches),
        .readData   (sw_readData)
    );

    // --------------------------------------------------------
    //  Read data mux: one device active at a time
    // --------------------------------------------------------
    assign readData = DataMemRead      ? mem_readData :
                      SwitchReadEnable ? sw_readData  :
                                         32'd0;

    assign leds = led_out;

endmodule