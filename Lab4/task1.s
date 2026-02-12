.text
.globl main
main:
    addi x5, x0, 8
    addi x6, x0, 1

    loop:
        mul x6, x6, x5
        addi x5, x5, -1
        bne x5, x0, loop
end:
    j end