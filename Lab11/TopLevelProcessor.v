`timescale 1ns / 1ps
module TopLevelProcessor (
 input wire clk,
 input wire rst,
 output [31:0] result
);
 wire [31:0] pc;
 wire [31:0] pc_next;
 wire [31:0] pc_plus4;
 wire [31:0] branch_target;
 wire [31:0] instruction;
 wire [6:0] opcode = instruction[6:0];
  wire [4:0] rs1 = instruction[19:15];
 wire [4:0] rs2 = instruction[24:20];
 wire [4:0] rd = instruction[11:7];
 wire [2:0] funct3 = instruction[14:12];
 wire [6:0] funct7 = instruction[31:25];
 wire [31:0] imm_ext;
 wire regWrite;
 wire memRead;
 wire memWrite_ctrl;
 wire aluSrc;
 wire memToReg;
 wire branch;
 wire [1:0] aluOp;
 wire [3:0] aluControl;
 wire [31:0] readData1;
 wire [31:0] readData2;
 wire [31:0] alu_b;
 wire [31:0] alu_result;
 wire carry_flag;
 wire zero_flag;
 wire pcsrc;
 wire [31:0] mem_readData;
 wire [31:0] wb_data;
 ProgramCounter pc_inst (
 .clk (clk),
 .reset (rst),
 .pc_next(pc_next),
 .pc (pc)
 );
 pcAdder pc_adder_inst (
 .pc (pc),
 .pc_plus4(pc_plus4)
 );
 instructionMemory imem_inst (
   .instAddress(pc),
   .instruction(instruction)
 );
 immGen imm_gen_inst (
 .instruction(instruction),
 .imm_out (imm_ext)
 );
 MainControl main_ctrl_inst (
 .opcode (opcode),
 .regWrite (regWrite),
 .memRead (memRead),
 .memWrite (memWrite_ctrl),
 .aluSrc (aluSrc),
 .memToReg (memToReg),
 .branch (branch),
 .aluOp (aluOp)
 );
 ALUControl alu_ctrl_inst (
 .aluOp (aluOp),
 .funct3 (funct3),
  .funct7 (funct7),
 .aluControlSignal(aluControl)
 );
 RegisterFile reg_file_inst (
 .clk (clk),
 .rst (rst),
 .WriteEnable(regWrite),
 .rs1 (rs1),
 .rs2 (rs2),
 .rd (rd),
 .WriteData (wb_data),
 .ReadData1 (readData1),
 .ReadData2 (readData2)
 );
 mux2 alu_src_mux (
 .in0(readData2),
 .in1(imm_ext),
 .sel(aluSrc),
 .out(alu_b)
 );
  ALU_32Bit alu_inst (
 .A (readData1),
 .B (alu_b),
 .ALUControl(aluControl),
 .carry_flag(carry_flag),
 .ALUResult (alu_result),
 .Zero (zero_flag)
 );
 assign pcsrc = branch & zero_flag;
 branchAdder branch_adder_inst (
 .pc (pc),
 .imm (imm_ext),
 .branch_target(branch_target)
 );
 mux2 pc_mux_inst (
 .in0(pc_plus4),
 .in1(branch_target),
 .sel(pcsrc),
 .out(pc_next)
 );
 DataMemory data_mem_inst (
 .clk (clk),
 .reset (rst),
 .MemWrite (memWrite_ctrl),
 .address (alu_result[9:0]),
 .WriteData(readData2),
 .ReadData (mem_readData)
 );
mux2 wb_mux_inst (
 .in0(alu_result),
 .in1(mem_readData),
 .sel(memToReg),
 .out(wb_data)
 );
assign result = wb_data;
endmodule
   
