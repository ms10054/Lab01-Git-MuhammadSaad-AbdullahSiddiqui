`timescale 1ns / 1ps

module ALU_32Bit(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [3:0] Control,
    output wire signal_out,
    output wire [31:0] Y,
    output wire Zero      
);
    
    wire [31:0] carry_propagate;
    wire [31:0] result_wire;
    wire [31:0] shift_output;
    wire shift_operation;
    
    assign shift_operation = (Control[2:0] == 3'b101);
    assign shift_output    = {A[31], A[31:1]};
    wire initial_carry = Control[0];
    
    ALU ALU0  (.a(A[0]),  .b(B[0]),  .control({initial_carry,     Control[2:0]}), .Y(carry_propagate[0]),  .Z(result_wire[0]));
    ALU ALU1  (.a(A[1]),  .b(B[1]),  .control({carry_propagate[0],  Control[2:0]}), .Y(carry_propagate[1]),  .Z(result_wire[1]));
    ALU ALU2  (.a(A[2]),  .b(B[2]),  .control({carry_propagate[1],  Control[2:0]}), .Y(carry_propagate[2]),  .Z(result_wire[2]));
    ALU ALU3  (.a(A[3]),  .b(B[3]),  .control({carry_propagate[2],  Control[2:0]}), .Y(carry_propagate[3]),  .Z(result_wire[3]));
    ALU ALU4  (.a(A[4]),  .b(B[4]),  .control({carry_propagate[3],  Control[2:0]}), .Y(carry_propagate[4]),  .Z(result_wire[4]));
    ALU ALU5  (.a(A[5]),  .b(B[5]),  .control({carry_propagate[4],  Control[2:0]}), .Y(carry_propagate[5]),  .Z(result_wire[5]));
    ALU ALU6  (.a(A[6]),  .b(B[6]),  .control({carry_propagate[5],  Control[2:0]}), .Y(carry_propagate[6]),  .Z(result_wire[6]));
    ALU ALU7  (.a(A[7]),  .b(B[7]),  .control({carry_propagate[6],  Control[2:0]}), .Y(carry_propagate[7]),  .Z(result_wire[7]));
    ALU ALU8  (.a(A[8]),  .b(B[8]),  .control({carry_propagate[7],  Control[2:0]}), .Y(carry_propagate[8]),  .Z(result_wire[8]));
    ALU ALU9  (.a(A[9]),  .b(B[9]),  .control({carry_propagate[8],  Control[2:0]}), .Y(carry_propagate[9]),  .Z(result_wire[9]));
    ALU ALU10 (.a(A[10]), .b(B[10]), .control({carry_propagate[9],  Control[2:0]}), .Y(carry_propagate[10]), .Z(result_wire[10]));
    ALU ALU11 (.a(A[11]), .b(B[11]), .control({carry_propagate[10], Control[2:0]}), .Y(carry_propagate[11]), .Z(result_wire[11]));
    ALU ALU12 (.a(A[12]), .b(B[12]), .control({carry_propagate[11], Control[2:0]}), .Y(carry_propagate[12]), .Z(result_wire[12]));
    ALU ALU13 (.a(A[13]), .b(B[13]), .control({carry_propagate[12], Control[2:0]}), .Y(carry_propagate[13]), .Z(result_wire[13]));
    ALU ALU14 (.a(A[14]), .b(B[14]), .control({carry_propagate[13], Control[2:0]}), .Y(carry_propagate[14]), .Z(result_wire[14]));
    ALU ALU15 (.a(A[15]), .b(B[15]), .control({carry_propagate[14], Control[2:0]}), .Y(carry_propagate[15]), .Z(result_wire[15]));
    ALU ALU16 (.a(A[16]), .b(B[16]), .control({carry_propagate[15], Control[2:0]}), .Y(carry_propagate[16]), .Z(result_wire[16]));
    ALU ALU17 (.a(A[17]), .b(B[17]), .control({carry_propagate[16], Control[2:0]}), .Y(carry_propagate[17]), .Z(result_wire[17]));
    ALU ALU18 (.a(A[18]), .b(B[18]), .control({carry_propagate[17], Control[2:0]}), .Y(carry_propagate[18]), .Z(result_wire[18]));
    ALU ALU19 (.a(A[19]), .b(B[19]), .control({carry_propagate[18], Control[2:0]}), .Y(carry_propagate[19]), .Z(result_wire[19]));
    ALU ALU20 (.a(A[20]), .b(B[20]), .control({carry_propagate[19], Control[2:0]}), .Y(carry_propagate[20]), .Z(result_wire[20]));
    ALU ALU21 (.a(A[21]), .b(B[21]), .control({carry_propagate[20], Control[2:0]}), .Y(carry_propagate[21]), .Z(result_wire[21]));
    ALU ALU22 (.a(A[22]), .b(B[22]), .control({carry_propagate[21], Control[2:0]}), .Y(carry_propagate[22]), .Z(result_wire[22]));
    ALU ALU23 (.a(A[23]), .b(B[23]), .control({carry_propagate[22], Control[2:0]}), .Y(carry_propagate[23]), .Z(result_wire[23]));
    ALU ALU24 (.a(A[24]), .b(B[24]), .control({carry_propagate[23], Control[2:0]}), .Y(carry_propagate[24]), .Z(result_wire[24]));
    ALU ALU25 (.a(A[25]), .b(B[25]), .control({carry_propagate[24], Control[2:0]}), .Y(carry_propagate[25]), .Z(result_wire[25]));
    ALU ALU26 (.a(A[26]), .b(B[26]), .control({carry_propagate[25], Control[2:0]}), .Y(carry_propagate[26]), .Z(result_wire[26]));
    ALU ALU27 (.a(A[27]), .b(B[27]), .control({carry_propagate[26], Control[2:0]}), .Y(carry_propagate[27]), .Z(result_wire[27]));
    ALU ALU28 (.a(A[28]), .b(B[28]), .control({carry_propagate[27], Control[2:0]}), .Y(carry_propagate[28]), .Z(result_wire[28]));
    ALU ALU29 (.a(A[29]), .b(B[29]), .control({carry_propagate[28], Control[2:0]}), .Y(carry_propagate[29]), .Z(result_wire[29]));
    ALU ALU30 (.a(A[30]), .b(B[30]), .control({carry_propagate[29], Control[2:0]}), .Y(carry_propagate[30]), .Z(result_wire[30]));
    ALU ALU31 (.a(A[31]), .b(B[31]), .control({carry_propagate[30], Control[2:0]}), .Y(carry_propagate[31]), .Z(result_wire[31]));
   
    assign Result     = shift_operation ? shift_output : result_wire;
    assign Y          = shift_operation ? A[0] : carry_propagate[31];
    assign Zero       = (Result == 32'b0);

endmodule