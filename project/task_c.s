.text
.globl main

main:

    lui  x31, 0x00010
    sw   x31, 0x200(x0)

    # Read switches
    # sw[3:0] = base
    # sw[7:4] = exponent
    lw   x5, 0x300(x0)      # x5 = switches

    andi x10, x5, 15        # x10 = base = sw[3:0]

    srli x11, x5, 4         # x11 = switches >> 4
    andi x11, x11, 15       # x11 = exponent = sw[7:4]

    addi x7, x0, 1          # x7 = result = 1


power_loop:
    beq  x11, x0, done      # if exponent == 0, finish

    addi x28, x0, 0         # x28 = product = 0
    addi x29, x7, 0         # x29 = counter = current result


mult_loop:
    beq  x29, x0, mult_done # if counter == 0, multiplication done

    add  x28, x28, x10      # product = product + base
    addi x29, x29, -1       # counter--

    beq  x0, x0, mult_loop  # unconditional jump


mult_done:
    addi x7, x28, 0         # result = product
    addi x11, x11, -1       # exponent--

    beq  x0, x0, power_loop # repeat power loop


done:
    sw   x7, 0x200(x0)      # write final result to FPGA output


end:
    beq  x0, x0, end        # stay here forever