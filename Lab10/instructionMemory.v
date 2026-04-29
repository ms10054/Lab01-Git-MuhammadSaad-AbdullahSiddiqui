

module instructionMemory #(
    parameter OPERAND_LENGTH = 31
)(
    input  [OPERAND_LENGTH:0] instAddress,
    output reg [31:0]         instruction
);

    // 256 � 8-bit byte array
    reg [7:0] memory [0:255];

    // ?? Initialise memory with FSM machine code ???????????????
    // Format: little-endian byte order per word
    // Each instruction stored at bytes [PC], [PC+1], [PC+2], [PC+3]
    //
    //  PC      Machine Code    Assembly
    //  0x00    1FC00113        addi sp, x0, 0x1FC
    //  0x04    00000393        addi t2, x0, 0
    //  0x08    20702023        sw t2, 0x200(x0)
    //  0x0C    30002283        lw t0, 0x300(x0)       <- WAIT_STATE
    //  0x10    FE028FE3        beq t0, x0, WAIT_STATE
    //  0x14    00028413        addi s0, t0, 0         <- CAPTURE
    //  0x18    20802023        sw s0, 0x200(x0)
    //  0x1C    FF810113        addi sp, sp, -8
    //  0x20    00112223        sw ra, 4(sp)
    //  0x24    00812023        sw s0, 0(sp)
    //  0x28    00040513        addi a0, s0, 0
    //  0x2C    014000EF        jal ra, COUNTDOWN
    //  0x30    00012403        lw s0, 0(sp)
    //  0x34    00412083        lw ra, 4(sp)
    //  0x38    00810113        addi sp, sp, 8
    //  0x3C    FD1FF06F        jal x0, WAIT_STATE
    //  0x40    20A02023        sw a0, 0x200(x0)       <- COUNTDOWN
    //  0x44    35002303        lw t1, 0x350(x0)
    //  0x48    00137313        andi t1, t1, 1
    //  0x4C    00031863        bne t1, x0, DO_RESET
    //  0x50    FFF50513        addi a0, a0, -1
    //  0x54    FC051EE3        bne a0, x0, COUNT_LOOP
    //  0x58    00008067        jalr x0, ra, 0  (ret)
    //  0x5C    00000393        addi t2, x0, 0         <- DO_RESET
    //  0x60    20702023        sw t2, 0x200(x0)
    //  0x64    00012403        lw s0, 0(sp)
    //  0x68    00412083        lw ra, 4(sp)
    //  0x6C    00810113        addi sp, sp, 8
    //  0x70    F9DFF06F        jal x0, WAIT_STATE

    initial begin
        // ?? Default: fill entire memory with NOP (addi x0,x0,0 = 0x00000013) ??
        // Using 0x00 bytes; processor should never reach beyond 0x70.
        // Remaining bytes default to 0x00 which decodes as addi x0,x0,0.
        begin : init_zeros
            integer i;
            for (i = 0; i < 256; i = i + 1)
                memory[i] = 8'h00;
        end

        // ?? PC = 0x00: addi sp, x0, 0x1FC  ?  0x1FC00113 ????
        memory[8'h00] = 8'h13;
        memory[8'h01] = 8'h01;
        memory[8'h02] = 8'hC0;
        memory[8'h03] = 8'h1F;

        // ?? PC = 0x04: addi t2, x0, 0      ?  0x00000393 ????
        memory[8'h04] = 8'h93;
        memory[8'h05] = 8'h03;
        memory[8'h06] = 8'h00;
        memory[8'h07] = 8'h00;

        // ?? PC = 0x08: sw t2, 0x200(x0)    ?  0x20702023 ????
        memory[8'h08] = 8'h23;
        memory[8'h09] = 8'h20;
        memory[8'h0A] = 8'h70;
        memory[8'h0B] = 8'h20;

        // ?? PC = 0x0C: lw t0, 0x300(x0)    ?  0x30002283  WAIT_STATE ??
        memory[8'h0C] = 8'h83;
        memory[8'h0D] = 8'h22;
        memory[8'h0E] = 8'h00;
        memory[8'h0F] = 8'h30;

        // ?? PC = 0x10: beq t0, x0, WAIT    ?  0xFE028FE3 ????
        memory[8'h10] = 8'hE3;
        memory[8'h11] = 8'h8E;
        memory[8'h12] = 8'h02;
        memory[8'h13] = 8'hFE;

        // ?? PC = 0x14: addi s0, t0, 0      ?  0x00028413  CAPTURE ??
        memory[8'h14] = 8'h13;
        memory[8'h15] = 8'h84;
        memory[8'h16] = 8'h02;
        memory[8'h17] = 8'h00;

        // ?? PC = 0x18: sw s0, 0x200(x0)    ?  0x20802023 ????
        memory[8'h18] = 8'h23;
        memory[8'h19] = 8'h20;
        memory[8'h1A] = 8'h80;
        memory[8'h1B] = 8'h20;

        // ?? PC = 0x1C: addi sp, sp, -8     ?  0xFF810113 ????
        memory[8'h1C] = 8'h13;
        memory[8'h1D] = 8'h01;
        memory[8'h1E] = 8'h81;
        memory[8'h1F] = 8'hFF;

        // ?? PC = 0x20: sw ra, 4(sp)        ?  0x00112223 ????
        memory[8'h20] = 8'h23;
        memory[8'h21] = 8'h22;
        memory[8'h22] = 8'h11;
        memory[8'h23] = 8'h00;

        // ?? PC = 0x24: sw s0, 0(sp)        ?  0x00812023 ????
        memory[8'h24] = 8'h23;
        memory[8'h25] = 8'h20;
        memory[8'h26] = 8'h81;
        memory[8'h27] = 8'h00;

        // ?? PC = 0x28: addi a0, s0, 0      ?  0x00040513 ????
        memory[8'h28] = 8'h13;
        memory[8'h29] = 8'h05;
        memory[8'h2A] = 8'h04;
        memory[8'h2B] = 8'h00;

        // ?? PC = 0x2C: jal ra, COUNTDOWN   ?  0x014000EF ????
        memory[8'h2C] = 8'hEF;
        memory[8'h2D] = 8'h00;
        memory[8'h2E] = 8'h40;
        memory[8'h2F] = 8'h01;

        // ?? PC = 0x30: lw s0, 0(sp)        ?  0x00012403 ????
        memory[8'h30] = 8'h03;
        memory[8'h31] = 8'h24;
        memory[8'h32] = 8'h01;
        memory[8'h33] = 8'h00;

        // ?? PC = 0x34: lw ra, 4(sp)        ?  0x00412083 ????
        memory[8'h34] = 8'h83;
        memory[8'h35] = 8'h20;
        memory[8'h36] = 8'h41;
        memory[8'h37] = 8'h00;

        // ?? PC = 0x38: addi sp, sp, 8      ?  0x00810113 ????
        memory[8'h38] = 8'h13;
        memory[8'h39] = 8'h01;
        memory[8'h3A] = 8'h81;
        memory[8'h3B] = 8'h00;

        // ?? PC = 0x3C: jal x0, WAIT_STATE  ?  0xFD1FF06F ????
        memory[8'h3C] = 8'h6F;
        memory[8'h3D] = 8'hF0;
        memory[8'h3E] = 8'h1F;
        memory[8'h3F] = 8'hFD;

        // ?? PC = 0x40: sw a0, 0x200(x0)    ?  0x20A02023  COUNTDOWN ??
        memory[8'h40] = 8'h23;
        memory[8'h41] = 8'h20;
        memory[8'h42] = 8'hA0;
        memory[8'h43] = 8'h20;

        // ?? PC = 0x44: lw t1, 0x350(x0)    ?  0x35002303 ????
        memory[8'h44] = 8'h03;
        memory[8'h45] = 8'h23;
        memory[8'h46] = 8'h00;
        memory[8'h47] = 8'h35;

        // ?? PC = 0x48: andi t1, t1, 1      ?  0x00137313 ????
        memory[8'h48] = 8'h13;
        memory[8'h49] = 8'h73;
        memory[8'h4A] = 8'h13;
        memory[8'h4B] = 8'h00;

        // ?? PC = 0x4C: bne t1, x0, DO_RST  ?  0x00031863 ????
        memory[8'h4C] = 8'h63;
        memory[8'h4D] = 8'h18;
        memory[8'h4E] = 8'h03;
        memory[8'h4F] = 8'h00;

        // ?? PC = 0x50: addi a0, a0, -1     ?  0xFFF50513 ????
        memory[8'h50] = 8'h13;
        memory[8'h51] = 8'h05;
        memory[8'h52] = 8'hF5;
        memory[8'h53] = 8'hFF;

        // ?? PC = 0x54: bne a0, x0, COUNT_LOOP ? 0xFC051EE3 ??
        memory[8'h54] = 8'hE3;
        memory[8'h55] = 8'h16;
        memory[8'h56] = 8'h05;
        memory[8'h57] = 8'hFE;

        // ?? PC = 0x58: jalr x0, ra, 0 (ret) ? 0x00008067 ????
        memory[8'h58] = 8'h67;
        memory[8'h59] = 8'h80;
        memory[8'h5A] = 8'h00;
        memory[8'h5B] = 8'h00;

        // ?? PC = 0x5C: addi t2, x0, 0      ?  0x00000393  DO_RESET ??
        memory[8'h5C] = 8'h93;
        memory[8'h5D] = 8'h03;
        memory[8'h5E] = 8'h00;
        memory[8'h5F] = 8'h00;

        // ?? PC = 0x60: sw t2, 0x200(x0)    ?  0x20702023 ????
        memory[8'h60] = 8'h23;
        memory[8'h61] = 8'h20;
        memory[8'h62] = 8'h70;
        memory[8'h63] = 8'h20;

        // ?? PC = 0x64: lw s0, 0(sp)        ?  0x00012403 ????
        memory[8'h64] = 8'h03;
        memory[8'h65] = 8'h24;
        memory[8'h66] = 8'h01;
        memory[8'h67] = 8'h00;

        // ?? PC = 0x68: lw ra, 4(sp)        ?  0x00412083 ????
        memory[8'h68] = 8'h83;
        memory[8'h69] = 8'h20;
        memory[8'h6A] = 8'h41;
        memory[8'h6B] = 8'h00;

        // ?? PC = 0x6C: addi sp, sp, 8      ?  0x00810113 ????
        memory[8'h6C] = 8'h13;
        memory[8'h6D] = 8'h01;
        memory[8'h6E] = 8'h81;
        memory[8'h6F] = 8'h00;

        // ?? PC = 0x70: jal x0, WAIT_STATE  ?  0xF9DFF06F ????
        memory[8'h70] = 8'h6F;
        memory[8'h71] = 8'hF0;
        memory[8'h72] = 8'hDF;
        memory[8'h73] = 8'hF9;
    end

    // ?? Instruction fetch: reconstruct 32-bit word from 4 bytes ??
    // PC is a byte address; instructions are word-aligned (PC[1:0] = 00)
    always @(*) begin
        instruction = {
            memory[instAddress + 3],   // bits [31:24]
            memory[instAddress + 2],   // bits [23:16]
            memory[instAddress + 1],   // bits [15:8]
            memory[instAddress + 0]    // bits  [7:0]
        };
    end

endmodule