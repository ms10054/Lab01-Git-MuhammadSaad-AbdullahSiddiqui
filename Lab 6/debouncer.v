`timescale 1ns / 1ps
module debouncer(
    input wire clk,
    input wire pbin,
    output reg pbout
    );
    
    reg [19:0] counter_val;
    reg        button_sync_0;
    reg        button_sync_1;
    
    // Synchronize input to clock domain
    always @(posedge clk) begin
        button_sync_0 <= pbin;
        button_sync_1 <= button_sync_0;
    end
    
    // Debounce logic
    always @(posedge clk) begin
        if (button_sync_1 == pbout) begin
            counter_val <= 20'd0;
        end
        else begin
            counter_val <= counter_val + 1'b1;
            if (counter_val == 20'd999_999) begin
                pbout <= button_sync_1;
                counter_val <= 20'd0;
            end
        end
    end
    
endmodule