' timescale 1ns / 1ps
module tb_top_system();
// Testbench signals
reg clk;
reg rst;
reg [15:0] tb_sw_pins;
wire [15:0] tb_led_pins;
wire [3:0] tb_countdown_out;
wire [6:0] tb_seg;
wire [3:0] tb_an;
// Instantiate the top module (DUT)
top_system uut (
.clk (clk),
.rst (rst),
.sw_pins (tb_sw_pins),
.led_pins (tb_led_pins),
.countdown_display (tb_countdown_out),
.seg (tb_seg),
.an (tb_an)
);
// Clock generation: 100 MHz (10 ns period)
always #5 clk = ~clk;
// Simulation control & stimulus
initial begin
// Initialize signals
clk = 0;
rst = 1;
tb_sw_pins = 16'b0000_0000_0000_0000;
// Dump waveform (very useful for debugging in Vivado simulator)
$dumpfile("tb_top_system.vcd");
$dumpvars(0, tb_top_system);
// Reset phase
#40; // wait 4 clock cycles
rst = 0;
#80; // wait a bit in idle state
$display("=====================================");
$display("Test 1: Single switch (SW4 = 1) → start from 4");
$display("=====================================");
tb_sw_pins = 16'b0000_0000_0001_0000; // SW4 (bit 4) → should count 4→3→2→1→0
#200; // give time to see countdown
$display("=====================================");
$display("Test 2: Higher switch (SW13 = 1) → start from 13");
$display("=====================================");
tb_sw_pins = 16'b0010_0000_0000_0000; // SW13 (bit 13) → 13→12→...→0
wait(tb_countdown_out == 4'd0); // wait until countdown finishes
#100;
$display("=====================================");
$display("Test 3: Reset during countdown");
$display("=====================================");
tb_sw_pins = 16'b0000_1000_0000_0000; // SW11 → start from 11
#150; // let it count down a bit
rst = 1;
#40;
rst = 0;
#100;
$display("=====================================");
$display("Test 4: All switches off → should stay in Idle");
$display("=====================================");
tb_sw_pins = 16'b0000_0000_0000_0000;
#200;
$display("Simulation finished successfully.");
$finish;
end
// Monitor important signals (helps a lot when watching console)
initial begin
$monitor("Time=%6t | rst=%b | sw=%04h | count=%2d | led=%04h | seg=%b",
$time, rst, tb_sw_pins, tb_countdown_out, tb_led_pins, tb_seg);
end
endmodule
