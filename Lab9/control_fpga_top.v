`timescale 1ns / 1ps

module control_fpga_top (
    input         clk,
    input         rst,
    input         btnU,
    input         btnC,
    input  [15:0] switches,
    output [15:0] leds
);

    // Debouncers
    wire cleanBtnU, cleanBtnC;

    debouncer dbU (.clk(clk), .pbin(btnU), .pbout(cleanBtnU));
    debouncer dbC (.clk(clk), .pbin(btnC), .pbout(cleanBtnC));

    // Slow clock
    reg [25:0] divider;
    always @(posedge clk or posedge rst)
        if (rst) divider <= 0;
        else divider <= divider + 1;

    wire slowClk = divider[25];

    // Switch module
    wire [31:0] switchValue;

    switches switchReader (
        .clk(clk),
        .rst(rst),
        .btns(16'b0),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readEnable(1'b1),
        .memAddress(30'b0),
        .switches(switches),   
        .readData(switchValue)
    );

    // Field extraction
    wire [6:0] opcode = switchValue[6:0];
    wire [2:0] funct3 = switchValue[9:7];
    wire [6:0] funct7 = {1'b0, switchValue[10], 5'b00000};

    // Control Unit
    wire regWrite, memRead, memWrite, aluSrc, memToReg, branch;
    wire [3:0] aluCtrl;

    control_top controlUnit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .regWrite(regWrite),
        .memRead(memRead),
        .memWrite(memWrite),
        .aluSrc(aluSrc),
        .memToReg(memToReg),
        .branch(branch),
        .aluControl(aluCtrl)
    );

    // FSM
    reg [1:0] dispState;
    parameter S_IDLE=0, S_READ=1, S_SHOW=2;

    always @(posedge slowClk or posedge rst) begin
        if (rst)
            dispState <= S_IDLE;
        else begin
            case (dispState)
                S_IDLE: dispState <= S_READ;
                S_READ: dispState <= S_SHOW;
                S_SHOW: dispState <= S_READ;
                default: dispState <= S_IDLE;
            endcase
        end
    end

    // LED Data
    wire [31:0] displayData;
    assign displayData = {22'b0, aluCtrl, branch, memToReg, aluSrc, memWrite, memRead, regWrite};

    // LED module
    leds ledDriver (
        .clk(clk),
        .rst(rst),
        .writeData(displayData),
        .writeEnable(dispState == S_SHOW), 
        .readEnable(1'b0),                  
        .memAddress(30'b0),                 
        .readData(),
        .leds(leds)
    );

Endmodule

`timescale 1ns / 1ps

module leds (
    input         clk,
    input         rst,
    input  [31:0] writeData,
    input         writeEnable,
    input         readEnable,
    input  [29:0] memAddress,
    output reg [31:0] readData,
    output reg [15:0] leds
);

    initial readData = 32'd0;

    always @(posedge clk or posedge rst) begin
        if (rst)
            leds <= 16'd0;
        else if (writeEnable)
            leds <= writeData[15:0];
    end

endmodule
