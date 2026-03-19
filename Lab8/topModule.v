`timescale 1ns / 1ps

module topModule (
    input         clk,
    input         rst,
    input  [15:0] sw,
    input  [15:0] btns,
    output [15:0] leds
);

    wire [31:0] cpu_addr;
    wire        cpu_rd_en;
    wire        cpu_wr_en;
    wire [31:0] cpu_wr_data;
    wire [31:0] cpu_rd_data;

 
    fsm u_fsm (
        .clk         (clk),
        .rst         (rst),
        .sw          (sw),
        .btns        (btns),
        .readData    (cpu_rd_data),
        .address     (cpu_addr),
        .readEnable  (cpu_rd_en),
        .writeEnable (cpu_wr_en),
        .writeData   (cpu_wr_data)
    );

    addressDecoderTop u_mem (
        .clk         (clk),
        .rst         (rst),
        .address     (cpu_addr),
        .readEnable  (cpu_rd_en),
        .writeEnable (cpu_wr_en),
        .writeData   (cpu_wr_data),
        .switches    (sw),
        .btns        (btns),
        .readData    (cpu_rd_data),
        .leds        (leds)
    );

endmodule