main:
    addi x5, x0, 5        # x5 = 5

loop:
    sw   x5, 0x200(x0)    # display x5
    addi x5, x5, -1       # x5 = x5 - 1
    bne  x5, x0, loop     # if x5 != 0, loop back

    sw   x5, 0x200(x0)    # display final 0

end:
    beq  x0, x0, end      # stay here