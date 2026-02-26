'timescale 1ns/ 1ps

module OR(
    input SW1,
    input SW2,
    output LED
);
or u1 (SW1, SW2, LED);
endmodule