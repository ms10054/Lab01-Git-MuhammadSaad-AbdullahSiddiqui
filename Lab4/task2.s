.text
.globl main
main:
    addi x10, x0, 10
    jal x1, sum
    mv x11, x10
    li x10, 1
    ecall
    beq x0, x0, end

    sum:
        addi sp, sp, -8 # adjust stack for 2 items
        sw x1 , 4(sp) # save return address
        sw x10 , 0(sp) # save argument n

        addi x5 , x10 , -1 # x5 = n - 1
        bge x5 , x0 , L1 # if (n - 1) >= 0, go to L1

        addi x10 , x0 , 0 # return 1
        addi sp , sp , 8 # pop stack
        jalr x0 , 0(x1) # return

    L1:
        addi x10 , x10 , -1 # argument = n - 1
        jal x1 , sum # recursive call

        addi x6 , x10 , 0 # save result of sum(n-1)
        lw x10 , 0(sp) # restore original n
        lw x1 , 4(sp) # restore return address
        addi sp , sp , 8 # pop stack

        add x10 , x10 , x6 # n * sum(n-1)
        jalr x0 , 0(x1)
end:
    j end                  
