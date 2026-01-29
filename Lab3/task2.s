.text
.globl main
main:
    li x18, 5
    li x19, 5 
    li x20, 5
    li x10, 10
    li x11, 8
    li x12, 4
    li x13, 8


    jal x1,func1
    li x10, 1 
    ecall
    end:
    j end
    # li x18, 0
    # li x19, 0
    # li x20, 0 
    func1:
        addi sp, sp -12
        sw x18, 8(sp)
        sw x19, 4(sp)
        sw x20, 0(sp)
        add x18, x10, x11
        add x19, x12, x13
        sub x20, x18, x19
        mv x11,x20

        lw x18, 8(sp)
        lw x19, 4(sp)
        lw x20, 0(sp)
        addi sp, sp, 12

        jalr x0,0(x1)