.text
.globl main
main:
    li x22, 10          # b = 10
    li x23, 5           # c = 5
    li x20, 3           # x = 3 
    
    li x5, 1
    beq x20, x5, Case1
    li x5, 2
    beq x20, x5, Case2

    li x5, 3
    beq x20, x5, Case3

    li x5, 4
    beq x20, x5, Case4

    j Default

Case1:
    add x21, x22, x23   # a = b + c
    j Exit
    
Case2:
    sub x21, x22, x23   # a = b - c
    j Exit
    
Case3:
    slli x21, x22, 1    # a = b * 2 (shift left by 1)
    j Exit
    
Case4:
    srai x21, x22, 1    # a = b / 2 (signed shift right by 1)
    j Exit
    
Default:
    li x21, 0           # a = 0
    
Exit:
    # End of program
end:
    j end