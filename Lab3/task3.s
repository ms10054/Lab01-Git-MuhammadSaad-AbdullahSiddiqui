.text
.globl main
main:
    li x10, 0x100
    
    li x5, 1
    sw x5, 0(x10)
    li x5, 2
    sw x5, 4(x10)
    li x5, 4
    sw x5, 8(x10)
    li x11, 2

    jal x1, swap

    addi x17, x0, 10
    ecall

    swap:
        slli x5, x11, 2
        add x5, x10, x5

        lw x6, 0(x5)
        lw x7, 4(x5)

        sw x7, 0(x5)
        sw x6, 4(x5)

        jalr x0, 0(x1)
end:
    j end