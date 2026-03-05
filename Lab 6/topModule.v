`timescale 1ns / 1ps

module topModule (
    input         clk,
    input         rst,
    input  [3:0]  sw,
    input  [3:0]  btns,
    output [15:0] leds
);
    wire [31:0] led_module_data;
    wire [31:0] switch_module_data;
    wire [31:0] data_to_write   = 32'd0;
    wire        write_enable    = 1'b0;
    wire        read_enable     = 1'b1;
    wire [29:0] memory_addr     = 30'd0;
    led led (
        .clk        (clk),
        .rst        (rst),
        .btns       ({12'd0, btns}),
        .writeData  (data_to_write),
        .writeEnable(write_enable),
        .readEnable (read_enable),
        .memAddress (memory_addr),
        .sw         ({12'd0, sw}),
        .readData   (led_module_data)
    );
    switches switches (
        .clk        (clk),
        .rst        (rst),
        .writeData  (data_to_write),
        .writeEnable(write_enable),
        .readEnable (read_enable),
        .memAddress (memory_addr),
        .readData   (switch_module_data),
        .leds       ()
    );
    assign leds = led_module_data[15:0];
endmodule