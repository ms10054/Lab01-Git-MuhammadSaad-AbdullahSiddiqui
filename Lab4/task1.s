.text
.globl main
main:
    addi x5, x0, 8 # n = 8
    addi x6, x0, 1  

    loop:
        mul x6, x6, x5  # x6 *= n
        addi x5, x5, -1 # n--
        bne x5, x0, loop # if n!=0, jump back to loop
end:
    j end