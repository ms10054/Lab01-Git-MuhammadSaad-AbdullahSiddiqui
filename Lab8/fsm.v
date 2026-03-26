`timescale 1ns / 1ps

module fsm(
    input             clk,
    input             rst,
    input      [15:0] sw,
    input      [15:0] btns,
    input      [31:0] readData,
    output reg [31:0] address,
    output reg        readEnable,
    output reg        writeEnable,
    output reg [31:0] writeData
);

    localparam [2:0]
        IDLE          = 3'd0,
        READ_SWITCHES = 3'd1,
        WRITE_DATAMEM = 3'd2,
        READ_DATAMEM  = 3'd3,
        WRITE_LED     = 3'd4;

    localparam [31:0]
        ADDR_DATAMEM = 32'h000,
        ADDR_LED     = 32'h100,
        ADDR_SWITCH  = 32'h200;

    reg [2:0]  state, next_state;
    reg [31:0] sw_captured;     // latched {btns, sw} from READ_SWITCHES


    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else     state <= next_state;
    end


    always @(posedge clk or posedge rst) begin
        if (rst)
            sw_captured <= 32'd0;
        else if (state == READ_SWITCHES)
            sw_captured <= {btns, sw};
    end


    always @(*) begin
        case (state)
            IDLE:          next_state = READ_SWITCHES;
            READ_SWITCHES: next_state = WRITE_DATAMEM;
            WRITE_DATAMEM: next_state = READ_DATAMEM;
            READ_DATAMEM:  next_state = WRITE_LED;
            WRITE_LED:     next_state = READ_SWITCHES;
            default:       next_state = IDLE;
        endcase
    end


    always @(*) begin
        address     = 32'd0;
        readEnable  = 1'b0;
        writeEnable = 1'b0;
        writeData   = 32'd0;

        case (state)
            READ_SWITCHES: begin
                address    = ADDR_SWITCH;
                readEnable = 1'b1;
            end
            WRITE_DATAMEM: begin
                address     = ADDR_DATAMEM;
                writeEnable = 1'b1;
                writeData   = sw_captured;
            end
            READ_DATAMEM: begin
                address    = ADDR_DATAMEM;
                readEnable = 1'b1;
            end
            WRITE_LED: begin
                address     = ADDR_LED;
                writeEnable = 1'b1;
                writeData   = sw_captured;
            end
            default: begin
                address     = 32'd0;
                readEnable  = 1'b0;
                writeEnable = 1'b0;
                writeData   = 32'd0;
            end
        endcase
    end

endmodule