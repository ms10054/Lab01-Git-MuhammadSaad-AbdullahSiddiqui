`timescale 1ns / 1ps

module addressDecoderTop (
    input         clk,
    input         rst,
    input  [31:0] address,
    input         readEnable,
    input         writeEnable,
    input  [31:0] writeData,
    input  [15:0] switches,
    input  [15:0] btns,
    output [31:0] readData,
    output [15:0] leds
);

    //---------------------------------------------------------
    // Peripheral select signals from address decoder
    //---------------------------------------------------------
    wire sel_datamem;
    wire sel_led;
    wire sel_sw;

    AddressDecoder u_decoder (
        .address         (address[9:0]),
        .DataMem         (sel_datamem),
        .LEDWrite        (sel_led),
        .SwitchReadEnable(sel_sw)
    );

    //---------------------------------------------------------
    // Data Memory
    //---------------------------------------------------------
    wire [31:0] mem_rd;

    DataMemory u_datamem (
        .clk      (clk),
        .reset    (rst),
        .MemWrite (sel_datamem & writeEnable),
        .address  (address[9:0]),
        .WriteData(writeData),
        .ReadData (mem_rd)
    );
    
    //---------------------------------------------------------
    // LED peripheral  (write-only - readData always 0)
    //---------------------------------------------------------
    wire [31:0] led_rd;

    leds u_leds (
        .clk        (clk),
        .rst        (rst),
        .writeData  (writeData),
        .writeEnable(sel_led & writeEnable),
        .readEnable (1'b0),
        .memAddress (address[29:0]),
        .readData   (led_rd),
        .leds       (leds)
    );

    //---------------------------------------------------------
    // Switch peripheral  (read-only)
    //---------------------------------------------------------
    wire [31:0] sw_rd;

    switches u_switches (
        .clk        (clk),
        .rst        (rst),
        .btns       (btns),
        .writeData  (writeData),
        .writeEnable(writeEnable),
        .readEnable (sel_sw & readEnable),
        .memAddress (address[29:0]),
        .sw         (switches),
        .readData   (sw_rd)
    );

    //---------------------------------------------------------
    // Read data mux - only one peripheral active at a time
    //---------------------------------------------------------
    assign readData = sel_sw      ? sw_rd  :
                      sel_datamem ? mem_rd :
                                    32'd0;

endmodule