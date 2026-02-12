.text
.globl main
main:
    li x5, 10
    li x6, 5
    li x7, 0
    li x20, 0

    loopA: li x29,0
        blt x7,x5, loopB
        beq x0, x0, end
    loopB: slli x20, x29, 2
        add x25, x7, x29 
        sw x25, 0x200(x20) 
        addi x29, x29, 1
        blt x29, x6, loopB
        addi x7, x7, 1
        beq x0, x0, loopA
end: 
    j end