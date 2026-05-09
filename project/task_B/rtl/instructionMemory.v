`timescale 1ns / 1ps

module instructionMemory(
    input  [31:0] instAddress,
    output reg [31:0] instruction
);

    reg [31:0] memory [0:255];

    initial begin
        $readmemh("prog.mem", memory);
    end

    always @(*) begin
        instruction = memory[instAddress[9:2]];
    end

endmodule