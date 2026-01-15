# .text
# .globl main
# main:
    # li x20, 5 # a = 5
    # li x21, 0 # b = 0+0
    # addi x20, x21, 32 # a = b + 32

    # add x22, x20, x21 # x22 = a + b
    # addi x23, x22, -5 # d = (a+b)-5

    # sub x24, x20, x23 # x24 = a-d
    # sub x25, x21, x20 # x25 = b-a
    # add x26, x24, x25 # x26 = x24+x25
    # add x27, x26, x23 # e = x26 + d
    # add x28, x22, x23 # x28 = a + b + d
    # add x27, x28, x27 # e = a + b + d + e


    #task 4a
    #i

    # li x10, 0x78786464
    # li x11, 0xA8A81919s

    # li x5, 0x100
    # sw x10, 0(x5)

    # #ii

    # li x6, 0x1F0
    # sw x11, 0(x6)

    # #iii
    # lhu x12, 0x100(0)

    # #iv
    # lh x13, 0x1F0(0)

    # #v
    # lb x14, 0x1F0(0)
   
   #task 4b

    # Load base addresses into registers
    # li   x20, 0x100     
    # li   x21, 0x200     
    # li   x22, 0x300     

    # # Iteration i=0: c[0] = a[0] + b[0]
    # lb   x8, 0(x20)     
    # lh   x9, 0(x21)      
    # add  x10, x8, x9    
    # sw   x10, 0(x22)     

    # Iteration i=1: c[1] = a[1] + b[1]
    # lb   x8, 1(x20)     
    # lh   x9, 2(x21)      
    # add  x10, x8, x9    
    # sw   x10, 4(x22)     

    # Iteration i=2: c[2] = a[2] + b[2]
    # lb   x8, 2(x20)     
    # lh   x9, 4(x21)     
    # add  x10, x8, x9    
    # sw   x10, 8(x22)     

    # Iteration i=3: c[3] = a[3] + b[3]
#     lb   x8, 3(x20)      
#     lh   x9, 6(x21)      
#     add  x10, x8, x9   
#     sw   x10, 12(x22) 

# end:
#     j end
