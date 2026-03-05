`timescale 1ns / 1ps
module ALU(
    input wire a,
    input wire b,
    input wire [3:0] control,
    output reg Y,
    output reg Z
    );
    
    wire carry_in = control[3];
    wire addsub_ctrl = control[0];
    wire logic_and;
    wire logic_or;
    wire logic_xor;
    wire shift_left_result; wire shift_left_carry;
    wire shift_right_result; wire shift_right_carry;
    wire arithmetic_result; wire arithmetic_carry;
    
    AND AND(
        .A(a),
        .B(b),
        .Z(logic_and)
    );
    
    OR OR(
        .A(a),
        .B(b),
        .Z(logic_or)
    );
    
    XOR XOR(
        .A(a),
        .B(b),
        .Z(logic_xor)
    );
    
    SLL SLL(
        .A(a),
        .signal_in(carry_in),
        .Z(shift_left_result),
        .signal_out(shift_left_carry)
    );
    
    SRL SRL(
        .A(a),
        .signal_in(carry_in),
        .Z(shift_right_result),
        .signal_out(shift_right_carry)
    );
    
    Fulladder fa(
        .a(a),
        .b(b),
        .signal(addsub_ctrl),
        .cin(carry_in),
        .y(arithmetic_result),
        .cout(arithmetic_carry)
    );
    
    always @(*) begin
    case(control)
        4'b0000: begin Z = logic_and;          Y = 0;                  end
        4'b0001: begin Z = logic_or;           Y = 0;                  end
        4'b0010: begin Z = logic_xor;          Y = 0;                  end
        4'b0100: begin Z = shift_left_result;  Y = shift_left_carry;   end
        4'b0101: begin Z = shift_right_result; Y = shift_right_carry;  end
        // dont care cases where addsub_ctrl doesnt matter
        4'b1000: begin Z = logic_and;          Y = 0;                  end
        4'b1001: begin Z = logic_or;           Y = 0;                  end
        4'b1010: begin Z = logic_xor;          Y = 0;                  end
        4'b1100: begin Z = shift_left_result;  Y = shift_left_carry;   end
        4'b1101: begin Z = shift_right_result; Y = shift_right_carry;  end
        4'b1110: begin Z = arithmetic_result;  Y = arithmetic_carry;   end   // cin = 1, sub = 0
        4'b1111: begin Z = arithmetic_result;  Y = arithmetic_carry;   end   // cin = 1, sub = 1
        4'b0110: begin Z = arithmetic_result;  Y = arithmetic_carry;   end   // cin = 0, sub = 0
        4'b0111: begin Z = arithmetic_result;  Y = arithmetic_carry;   end   // cin = 0, sub = 1
        default: begin Z = 0;                  Y = 0;                  end
    endcase
end
    
endmodule