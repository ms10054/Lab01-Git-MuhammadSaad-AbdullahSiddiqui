.text
.globl main
main:
    li x20, 5 # a = 5
    li x21, 0 # b = 0+0
    addi x20, x21, 32 # a = b + 32

    add x22, x20, x21 # x22 = a + b
    addi x23, x22, -5 # d = (a+b)-5

    sub x24, x20, x23 # x24 = a-d
    sub x25, x21, x20 # x25 = b-a
    add x26, x24, x25 # x26 = x24+x25
    add x27, x26, x23 # e = x26 + d
    add x28, x22, x23 # x28 = a + b + d
    add x27, x28, x27 # e = a + b + d + e
end:
    j end
