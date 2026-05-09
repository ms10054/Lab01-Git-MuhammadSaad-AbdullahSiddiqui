main:
    addi x5, x0, 255
    andi x5, x5, 15
    sw   x5, 0x200(x0)

    lui  x5, 0x00010
    sw   x5, 0x200(x0)

end:
    beq  x0, x0, end