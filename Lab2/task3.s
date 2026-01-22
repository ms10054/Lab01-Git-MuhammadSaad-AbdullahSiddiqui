.text
.globl main
main:

    li x20, 0x200       # x20 = base address of array a (0x200)
    li x23, 0           # sum = 0 (x23)
    
    li x22, 0           # i = 0 (x22)
    li x5, 10           # loop limit = 10
    
Loop1:
    beq x22, x5, EndLoop1   # if i == 10, exit loop
    bne x22, x5, Body1      # if i != 10, execute loop body
    
Body1:
    slli x6, x22, 2         # x6 = i * 4 (word offset)
    add x6, x6, x20         # x6 = address of a[i]
    sw x22, 0(x6)           # a[i] = i
    addi x22, x22, 1        # i = i + 1
    j Loop1                 # repeat loop
    
EndLoop1:
    
    li x22, 0           # i = 0 (reset x22)
    li x5, 10           # loop limit = 10
    
Loop2:
    beq x22, x5, EndLoop2   # if i == 10, exit loop
    bne x22, x5, Body2      # if i != 10, execute loop body
    
Body2:
    slli x6, x22, 2         # x6 = i * 4 (word offset)
    add x6, x6, x20         # x6 = address of a[i]
    lw x7, 0(x6)            # x7 = a[i]
    add x23, x23, x7        # sum = sum + a[i] (x23)
    addi x22, x22, 1        # i = i + 1
    j Loop2                 # repeat loop
    
EndLoop2:

    
Exit:
end:
    j end