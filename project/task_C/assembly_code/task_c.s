main:
    lw   x5, 0x300(x0)      # read switches
    andi x5, x5, 15         # x5 = n = sw[3:0]

    addi x6, x0, 1          # x6 = result = 1
    addi x7, x5, 0          # x7 = counter = n

    beq  x7, x0, done       # if n == 0, skip loops

factorial_loop:
    addi x8, x0, 0          # product = 0
    addi x9, x7, 0          # multiplication counter = x7

mult_loop:
    add  x8, x8, x6         # product += result
    addi x9, x9, -1
    bne  x9, x0, mult_loop

    addi x6, x8, 0          # result = product
    addi x7, x7, -1
    bne  x7, x0, factorial_loop

done:
    lui  x10, 0x00010       # x10 = 0x00010000
    add  x10, x10, x6       # x10 = 0x00010000 + n!
    sw   x10, 0x200(x0)     # output result

end:
    beq  x0, x0, end