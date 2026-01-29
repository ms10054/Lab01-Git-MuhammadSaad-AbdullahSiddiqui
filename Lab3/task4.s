.text
.globl main
main:
    li x10, 0x100
    li x11, 0x200

    li x5, 72
    sb x5, 0(x11)
    li x5, 101
    sb x5, 1(x11)
    li x5, 121
    sb x5, 2(x11)
    li x5, 0
    sb x5, 3(x11)

    jal x1, strcpy
    li x6, 10
    ecall

    strcpy:
        addi sp, sp, -4
        sw x20, 0(sp)
        add x20, x0, x0

    loop1:
        add x5, x20, x11
        lbu x7, 0(x5)
        add x8, x20, x10
        sb x7, 0(x8)
        beq x7, x0, loop2
        addi x20, x20, 1
        j loop1

    loop2:
        lw x20, 0(sp)
        addi sp, sp, 4
        jalr x0, 0(x1)

end:
    j end