module mux2 (
    input  wire [31:0] in0,      // PC + 4  (PCSrc = 0)
    input  wire [31:0] in1,      // branch target (PCSrc = 1)
    input  wire        sel,      // PCSrc control signal
    output wire [31:0] out
);
    assign out = sel ? in1 : in0;

endmodule