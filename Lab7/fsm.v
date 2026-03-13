`timescale 1ns / 1ps

module fsm (
    input             clk,
    input             rst,
    input      [3:0]  sw_in,
    output reg [3:0]  led_out,
    output reg [3:0]  ALUControl,
    output reg        cnt_en
);

    localparam IDLE   = 1'b0,
               ACTIVE = 1'b1;

    reg current_state;

    // Clock divider: 100 MHz → ~1 Hz (toggles every 0.5 s)
    reg [26:0] divider_count;
    reg        divided_clk;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            divider_count <= 27'd0;
            divided_clk   <= 1'b0;
        end else begin
            if (divider_count == 27'd49_999_999) begin
                divider_count <= 27'd0;
                divided_clk   <= ~divided_clk;
            end else begin
                divider_count <= divider_count + 1;
            end
        end
    end

    // FSM state register + output logic
    always @(posedge divided_clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            led_out       <= 4'd0;
            ALUControl    <= 4'd0;
            cnt_en        <= 1'b0;
        end else begin
            case (current_state)

                IDLE: begin
                    cnt_en  <= 1'b0;
                    led_out <= 4'd0;
                    if (sw_in != 4'd0) begin
                        ALUControl    <= sw_in;
                        led_out       <= sw_in;
                        current_state <= ACTIVE;
                    end
                end

                ACTIVE: begin
                    cnt_en     <= 1'b1;
                    ALUControl <= sw_in;
                    led_out    <= sw_in;
                    if (sw_in == 4'd0) begin
                        cnt_en        <= 1'b0;
                        led_out       <= 4'd0;
                        current_state <= IDLE;
                    end
                end

                default: current_state <= IDLE;
            endcase
        end
    end

endmodule