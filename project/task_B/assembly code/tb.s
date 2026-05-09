.text
.globl main

main:
    addi x5, x0, 255        # x5 = 255
    andi x5, x5, 15         # x5 = 255 & 15 = 15
    sw   x5, 0x200(x0)      # display 15 on FPGA output

    lui  x5, 0x00010        # x5 = 0x00010000
    sw   x5, 0x200(x0)      # display 0x00010000

    addi x6, x0, 5          # x6 = 5

bne_loop:
    addi x6, x6, -1         # x6 = x6 - 1
    bne  x6, x0, bne_loop   # loop while x6 != 0

    addi x5, x0, 7          # x5 = 7
    sw   x5, 0x200(x0)      # display final 7

end:
    beq  x0, x0, end        # stay here forever