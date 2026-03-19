`timescale 1ns / 1ps

module MemorySystem_tb;

    reg        clk;
    reg        rst;
    reg [15:0] sw;
    reg [15:0] btns;

    wire [31:0] address;
    wire        readEnable;
    wire        writeEnable;
    wire [31:0] writeData;
    wire [31:0] readData;

    wire        DataMem;
    wire        LEDWrite;
    wire        SwitchReadEnable;

    wire [15:0] leds;

    fsm u_fsm (
        .clk        (clk),
        .rst        (rst),
        .sw         (sw),
        .btns       (btns),
        .readData   (readData),
        .address    (address),
        .readEnable (readEnable),
        .writeEnable(writeEnable),
        .writeData  (writeData)
    );

    AddressDecoder u_decoder (
        .address         (address[9:0]),
        .DataMem         (DataMem),
        .LEDWrite        (LEDWrite),
        .SwitchReadEnable(SwitchReadEnable)
    );

    addressDecoderTop u_mem (
        .clk        (clk),
        .rst        (rst),
        .address    (address),
        .readEnable (readEnable),
        .writeEnable(writeEnable),
        .writeData  (writeData),
        .switches   (sw),
        .btns       (btns),
        .readData   (readData),
        .leds       (leds)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task wait_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge clk);
            #1;
        end
    endtask

    task do_reset;
        begin
            rst = 1;
            wait_cycles(3);
            rst = 0;
            wait_cycles(2);
        end
    endtask

    integer pass_count;
    integer fail_count;

    initial begin
        clk        = 0;
        rst        = 0;
        sw         = 16'd0;
        btns       = 16'd0;
        pass_count = 0;
        fail_count = 0;

        $display("======================================");
        $display("   MemorySystem Testbench Starting    ");
        $display("======================================");

        // -------------------------------------------------------
        // Test 1: Reset clears LEDs
        // -------------------------------------------------------
        $display("\n=== Test 1: Reset clears LEDs ===");
        sw = 16'hF0F0;
        do_reset;
        if (leds === 16'd0) begin
            $display("PASS: leds = 0x%04X after reset", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: leds = 0x%04X (expected 0x0000)", leds);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 2: Lower byte only
        // -------------------------------------------------------
        $display("\n=== Test 2: Lower byte only (sw=0x00FF) ===");
        sw = 16'h00FF;
        wait_cycles(15);
        if (leds === 16'h00FF) begin
            $display("PASS: leds = 0x%04X", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: leds = 0x%04X (expected 0x00FF)", leds);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 3: Upper byte only
        // -------------------------------------------------------
        $display("\n=== Test 3: Upper byte only (sw=0xFF00) ===");
        sw = 16'hFF00;
        wait_cycles(15);
        if (leds === 16'hFF00) begin
            $display("PASS: leds = 0x%04X", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: leds = 0x%04X (expected 0xFF00)", leds);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 4: All switches ON
        // -------------------------------------------------------
        $display("\n=== Test 4: All switches ON (sw=0xFFFF) ===");
        sw = 16'hFFFF;
        wait_cycles(15);
        if (leds === 16'hFFFF) begin
            $display("PASS: leds = 0x%04X", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: leds = 0x%04X (expected 0xFFFF)", leds);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 5: All switches OFF
        // -------------------------------------------------------
        $display("\n=== Test 5: All switches OFF (sw=0x0000) ===");
        sw = 16'h0000;
        wait_cycles(15);
        if (leds === 16'h0000) begin
            $display("PASS: leds = 0x%04X", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: leds = 0x%04X (expected 0x0000)", leds);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 6: Reset mid-run then recover
        // -------------------------------------------------------
        $display("\n=== Test 6: Reset mid-run then recover ===");
        sw = 16'hC3C3;
        wait_cycles(5);
        do_reset;
        if (leds === 16'h0000) begin
            $display("PASS: leds = 0x%04X immediately after reset", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: leds = 0x%04X after reset (expected 0x0000)", leds);
            fail_count = fail_count + 1;
        end
        wait_cycles(15);
        if (leds === 16'hC3C3) begin
            $display("PASS: leds = 0x%04X after recovery", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: leds = 0x%04X after recovery (expected 0xC3C3)", leds);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 7: Dynamic switch changes
        // -------------------------------------------------------
        $display("\n=== Test 7: Dynamic switch changes ===");
        sw = 16'h0F0F;
        wait_cycles(15);
        sw = 16'hF0F0;
        wait_cycles(15);
        if (leds === 16'hF0F0) begin
            $display("PASS: leds = 0x%04X after switch change", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: leds = 0x%04X (expected 0xF0F0)", leds);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 8: Address decoder - DataMem select
        // -------------------------------------------------------
        $display("\n=== Test 8: Address Decoder - DataMem select ===");
        // FSM goes to WRITE_DATAMEM which uses address 0x000 (bits [9:8] = 00)
        sw = 16'hABCD;
        wait_cycles(5);
        if (address[9:8] === 2'b00 && DataMem === 1'b1) begin
            $display("PASS: DataMem selected when address[9:8] = 00");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: DataMem = %b, address[9:8] = %b (expected DataMem=1, addr=00)", DataMem, address[9:8]);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 9: Address decoder - LED select
        // -------------------------------------------------------
        $display("\n=== Test 9: Address Decoder - LED select ===");
        // FSM goes to WRITE_LED which uses address 0x100 (bits [9:8] = 01)
        wait_cycles(3);
        if (address[9:8] === 2'b01 && LEDWrite === 1'b1) begin
            $display("PASS: LEDWrite selected when address[9:8] = 01");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: LEDWrite = %b, address[9:8] = %b (expected LEDWrite=1, addr=01)", LEDWrite, address[9:8]);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 10: Address decoder - Switch select
        // -------------------------------------------------------
        $display("\n=== Test 10: Address Decoder - Switch select ===");
        // FSM goes to READ_SWITCHES which uses address 0x200 (bits [9:8] = 10)
        wait_cycles(2);
        if (address[9:8] === 2'b10 && SwitchReadEnable === 1'b1) begin
            $display("PASS: SwitchReadEnable selected when address[9:8] = 10");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: SwitchReadEnable = %b, address[9:8] = %b (expected SwitchReadEnable=1, addr=10)", SwitchReadEnable, address[9:8]);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 11: Button inputs reflected in LEDs
        // -------------------------------------------------------
        $display("\n=== Test 11: Button inputs reflected in LEDs ===");
        sw   = 16'h0000;
        btns = 16'hBEEF;
        wait_cycles(15);
        // FSM captures {btns, sw} but only lower 16 bits go to LEDs
        if (leds === 16'h0000) begin
            $display("PASS: leds = 0x%04X (sw=0, btns do not affect leds directly)", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: leds = 0x%04X (expected 0x0000)", leds);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 12: DataMemory reset initializes to index values
        // -------------------------------------------------------
        $display("\n=== Test 12: DataMemory reset initializes to index values ===");
        do_reset;
        // After reset, Memory[0] should be 0, Memory[1] should be 1 etc.
        // FSM will read from address 0x000 in READ_DATAMEM state
        // Wait for FSM to reach READ_DATAMEM
        wait_cycles(3);
        $display("INFO: readData = 0x%08X after reset (DataMem[0] should be 0)", readData);
        if (readData === 32'd0) begin
            $display("PASS: DataMemory[0] = %0d after reset", readData);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: DataMemory[0] = %0d (expected 0)", readData);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 13: Alternating switch pattern
        // -------------------------------------------------------
        $display("\n=== Test 13: Alternating pattern (sw=0xAAAA) ===");
        sw   = 16'hAAAA;
        btns = 16'd0;
        wait_cycles(15);
        if (leds === 16'hAAAA) begin
            $display("PASS: leds = 0x%04X", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: leds = 0x%04X (expected 0xAAAA)", leds);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 14: Alternating inverse pattern
        // -------------------------------------------------------
        $display("\n=== Test 14: Inverse alternating pattern (sw=0x5555) ===");
        sw = 16'h5555;
        wait_cycles(15);
        if (leds === 16'h5555) begin
            $display("PASS: leds = 0x%04X", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: leds = 0x%04X (expected 0x5555)", leds);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Test 15: Multiple resets
        // -------------------------------------------------------
        $display("\n=== Test 15: Multiple consecutive resets ===");
        sw = 16'hDEAD;
        wait_cycles(10);
        do_reset;
        do_reset;
        do_reset;
        if (leds === 16'h0000) begin
            $display("PASS: leds = 0x%04X after multiple resets", leds);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: leds = 0x%04X (expected 0x0000)", leds);
            fail_count = fail_count + 1;
        end

        // -------------------------------------------------------
        // Summary
        // -------------------------------------------------------
        $display("\n======================================");
        $display("         Testbench Summary            ");
        $display("======================================");
        $display("  PASSED: %0d / %0d", pass_count, pass_count + fail_count);
        $display("  FAILED: %0d / %0d", fail_count, pass_count + fail_count);
        $display("======================================");

        $finish;
    end

endmodule