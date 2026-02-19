
`timescale 1ns/1ps

module fsm_counter (
    input         clk,
    input         rst,          // synchronous reset
    input  [15:0] switch_in,    // switch value (debounced)
    output reg [15:0] leds,     // LED output showing countdown
    output reg        state_out // 0 = S0, 1 = S1  (for debug/testbench)
);

    // State encoding
    localparam S0 = 1'b0;
    localparam S1 = 1'b1;

    reg        state, next_state;
    reg [15:0] counter;

    always @(posedge clk) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            S0: begin
                if (switch_in != 16'd0)
                    next_state = S1;
                else
                    next_state = S0;
            end
            S1: begin
                if (rst || switch_in == 16'hFFFF || counter == 16'd0)
                    // 'reset' input or countdown finished → back to S0
                    next_state = S0;
                else
                    next_state = S1;
            end
            default: next_state = S0;
        endcase
    end

   
    always @(posedge clk) begin
        if (rst) begin
            counter <= 16'd0;
            leds    <= 16'd0;
        end else begin
            case (state)
                S0: begin
                    // Pre-load counter when a non-zero switch value is seen
                    if (switch_in != 16'd0) begin
                        counter <= switch_in;
                        leds    <= switch_in;
                    end else begin
                        counter <= 16'd0;
                        leds    <= 16'd0;
                    end
                end
                S1: begin
                    if (counter > 16'd0) begin
                        counter <= counter - 16'd1;
                        leds    <= counter - 16'd1;
                    end else begin
                        counter <= 16'd0;
                        leds    <= 16'd0;
                    end
                end
            endcase
        end
    end

    // Debug output
    always @(*) state_out = state;

endmodule


module debouncer (
    input  clk,
    input  pbin,
    output pbout
);
    reg [2:0] shift;
    always @(posedge clk)
        shift <= {shift[1:0], pbin};
    assign pbout = (shift[2] & shift[1]) | (shift[2] & shift[0]) | (shift[1] & shift[0]);
endmodule


module leds (
    input         clk,
    input         rst,
    input  [15:0] btns,
    input  [31:0] writeData,
    input         writeEnable,
    input         readEnable,
    input  [29:0] memAddress,
    input  [15:0] switches,
    output reg [31:0] readData
);
    // In this lab the LED output is driven by fsm_counter.
    // This stub satisfies the interface requirement.
    always @(posedge clk)
        readData <= 32'd0;
endmodule


module switches (
    input         clk,
    input         rst,
    input  [31:0] writeData,
    input         writeEnable,
    input         readEnable,
    input  [29:0] memAddress,
    output reg [31:0] readData,
    output reg [15:0] leds_out
);
    always @(posedge clk) begin
        readData <= 32'd0;
        leds_out <= 16'd0;
    end
endmodule