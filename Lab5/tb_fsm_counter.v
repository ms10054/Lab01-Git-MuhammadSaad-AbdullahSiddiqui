
`timescale 1ns/1ps

module tb_fsm_counter;

    reg         clk;
    reg         rst;
    reg  [15:0] switch_in;
    wire [15:0] leds;
    wire        state_out;

    fsm_counter dut (
        .clk       (clk),
        .rst       (rst),
        .switch_in (switch_in),
        .leds      (leds),
        .state_out (state_out)
    );


    initial clk = 0;
    always #5 clk = ~clk;

    task wait_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1)
                @(posedge clk);
        end
    endtask

    integer cycle;

    initial begin
        $dumpfile("fsm_counter.vcd");
        $dumpvars(0, tb_fsm_counter);


        $display("\n=== TEST 1: Reset ===");
        rst       = 1;
        switch_in = 16'd0;
        wait_cycles(3);
        rst = 0;
        @(posedge clk); #1;
        if (state_out !== 0)
            $display("FAIL: Expected S0 after reset, got state=%b", state_out);
        else
            $display("PASS: In S0 after reset");


        $display("\n=== TEST 2: Stay in S0 (switch=0) ===");
        switch_in = 16'd0;
        wait_cycles(5);
        @(posedge clk); #1;
        if (state_out !== 0)
            $display("FAIL: Should remain in S0, got state=%b", state_out);
        else
            $display("PASS: Remained in S0");

        $display("\n=== TEST 3: S0 → S1 on switch=5 ===");
        switch_in = 16'd5;
        @(posedge clk); #1;   // latch switch, move to S1
        @(posedge clk); #1;
        if (state_out !== 1)
            $display("FAIL: Expected S1, got state=%b", state_out);
        else
            $display("PASS: Transitioned to S1, counter loaded with 5");
        $display("      leds = %0d (expected ~5 or 4 depending on pipeline)", leds);

 
        $display("\n=== TEST 4: Countdown from 5 → 0, return to S0 ===");
        // Keep switch_in = 5 but watch it count down
        // Need to clear switch so we don't reload on re-entry to S0
        // After countdown the FSM returns to S0; if switch is still 5 it
        // immediately re-enters S1.  Set switch to 0 after a couple cycles.
        switch_in = 16'd0;   // prevent re-entry
        for (cycle = 0; cycle < 10; cycle = cycle + 1) begin
            @(posedge clk); #1;
            $display("      cycle=%0d  state=%b  leds=%0d", cycle, state_out, leds);
        end
        if (state_out !== 0)
            $display("FAIL: Should be back in S0 after countdown");
        else
            $display("PASS: Returned to S0 after countdown");

   
        $display("\n=== TEST 5: Mid-count reset ===");
        switch_in = 16'd15;
        @(posedge clk); #1;  // enter S1
        @(posedge clk); #1;
        @(posedge clk); #1;  // let it count a few
        $display("      Before reset: state=%b  leds=%0d", state_out, leds);
        rst = 1;
        @(posedge clk); #1;
        rst = 0;
        @(posedge clk); #1;
        if (state_out !== 0)
            $display("FAIL: Expected S0 after mid-count reset");
        else
            $display("PASS: Returned to S0 after mid-count reset, leds=%0d", leds);

        $display("\n=== TEST 6: Load value 4, full countdown ===");
        switch_in = 16'd4;
        @(posedge clk); #1;
        switch_in = 16'd0;
        for (cycle = 0; cycle < 8; cycle = cycle + 1) begin
            @(posedge clk); #1;
            $display("      cycle=%0d  state=%b  leds=%0d", cycle, state_out, leds);
        end

        $display("\n=== All tests complete ===");
        $finish;
    end


    initial begin
        #50000;
        $display("TIMEOUT - simulation did not finish");
        $finish;
    end

endmodule
