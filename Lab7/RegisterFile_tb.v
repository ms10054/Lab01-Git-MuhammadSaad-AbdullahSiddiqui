`timescale 1ns / 1ps

module RegisterFile_tb;

    reg         clk, rst;
    reg         WriteEnable;
    reg  [4:0]  rs1, rs2, rd;
    reg  [31:0] WriteData;
    wire [31:0] ReadData1, ReadData2;

    RegisterFile dut (
        .clk        (clk),
        .rst        (rst),
        .WriteEnable(WriteEnable),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .WriteData  (WriteData),
        .ReadData1  (ReadData1),
        .ReadData2  (ReadData2)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task check;
        input [31:0]   got;
        input [31:0]   expected;
        input [8*40:1] label;
        begin
            if (got === expected)
                $display("PASS  [%0t ns]  %0s  got=0x%08X", $time, label, got);
            else
                $display("FAIL  [%0t ns]  %0s  got=0x%08X  exp=0x%08X",
                         $time, label, got, expected);
        end
    endtask

    initial begin
        $dumpfile("RegisterFile_tb.vcd");
        $dumpvars(0, RegisterFile_tb);

        // Reset
        rst = 1; WriteEnable = 0;
        rd = 0; WriteData = 0; rs1 = 0; rs2 = 0;
        @(posedge clk); #1;
        rst = 0;

        // TC1: Write x5 = 0xDEADBEEF, read back next clock
        rd = 5; WriteData = 32'hDEADBEEF; WriteEnable = 1;
        @(posedge clk); #1;
        WriteEnable = 0;
        rs1 = 5; #1;
        check(ReadData1, 32'hDEADBEEF, "TC1 x5 write-then-read  ");

        // TC2: Write to x0, must stay zero
        rd = 0; WriteData = 32'hFFFFFFFF; WriteEnable = 1;
        @(posedge clk); #1;
        WriteEnable = 0;
        rs1 = 0; #1;
        check(ReadData1, 32'd0, "TC2 x0 always zero      ");

        // TC3: Simultaneous two-port read
        rd = 1; WriteData = 32'hAAAAAAAA; WriteEnable = 1;
        @(posedge clk); #1;
        rd = 2; WriteData = 32'h55555555;
        @(posedge clk); #1;
        WriteEnable = 0;
        rs1 = 1; rs2 = 2; #1;
        check(ReadData1, 32'hAAAAAAAA, "TC3 dual-read rs1=x1    ");
        check(ReadData2, 32'h55555555, "TC3 dual-read rs2=x2    ");

        // TC4: Overwrite x5 and verify
        rd = 5; WriteData = 32'h12345678; WriteEnable = 1;
        @(posedge clk); #1;
        WriteEnable = 0;
        rs1 = 5; #1;
        check(ReadData1, 32'h12345678, "TC4 x5 overwrite        ");

        // TC5: Reset clears all registers
        rst = 1;
        @(posedge clk); #1;
        rst = 0;
        rs1 = 5; rs2 = 1; #1;
        check(ReadData1, 32'd0, "TC5 reset clears x5     ");
        check(ReadData2, 32'd0, "TC5 reset clears x1     ");

        $display("\n--- RegisterFile testbench complete ---");
        $finish;
    end

endmodule