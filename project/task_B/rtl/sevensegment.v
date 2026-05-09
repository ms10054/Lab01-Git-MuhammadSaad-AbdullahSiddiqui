`timescale 1ns / 1ps

module sevensegment (
    input             clk,
    input      [15:0] data,
    output reg  [6:0] seg,
    output reg  [3:0] an
);

    // =========================================================
    // Clock divider: 100 MHz -> ~1 kHz for flicker-free mux
    // =========================================================
    reg [16:0] clkDiv   = 17'd0;
    reg [1:0]  digit_sel = 2'd0;

    always @(posedge clk) begin
        if (clkDiv == 17'd99999) begin
            clkDiv    <= 17'd0;
            digit_sel <= digit_sel + 1;
        end else begin
            clkDiv <= clkDiv + 1;
        end
    end

    // =========================================================
    // Inline BCD conversion (double-dabble, 16-bit)
    // Avoids dependency on a separate bin2bcd submodule
    // =========================================================
    reg [3:0] thousands, hundreds, tens, ones;
    integer i;

    always @(*) begin
        thousands = 4'd0;
        hundreds  = 4'd0;
        tens      = 4'd0;
        ones      = 4'd0;

        for (i = 15; i >= 0; i = i - 1) begin
            // Add 3 to any BCD digit >= 5 (double-dabble rule)
            if (thousands >= 4'd5) thousands = thousands + 4'd3;
            if (hundreds  >= 4'd5) hundreds  = hundreds  + 4'd3;
            if (tens      >= 4'd5) tens      = tens      + 4'd3;
            if (ones      >= 4'd5) ones      = ones      + 4'd3;

            // Shift left: MSB of each BCD digit feeds into LSB of next
            thousands = {thousands[2:0], hundreds[3]};
            hundreds  = {hundreds[2:0],  tens[3]};
            tens      = {tens[2:0],      ones[3]};
            ones      = {ones[2:0],      data[i]};
        end
    end

    // =========================================================
    // Digit selection (active-low anodes for Basys3)
    // =========================================================
    reg [3:0] current_digit;

    always @(*) begin
        case (digit_sel)
            2'b00: begin an = 4'b1110; current_digit = ones;      end // rightmost
            2'b01: begin an = 4'b1101; current_digit = tens;      end
            2'b10: begin an = 4'b1011; current_digit = hundreds;  end
            2'b11: begin an = 4'b0111; current_digit = thousands; end // leftmost
            default: begin an = 4'b1111; current_digit = 4'd0;   end
        endcase
    end

    // =========================================================
    // 7-segment decode - active LOW, segments: gfedcba
    // =========================================================
    always @(*) begin
        case (current_digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111; // blank
        endcase
    end

endmodule