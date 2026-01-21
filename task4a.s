.text
.globl main
main:
    #task 4a
    #i
    li x10, 0x78786464
    li x11, 0xA8A81919s

    li x5, 0x100
    sw x10, 0(x5)

    #ii

    li x6, 0x1F0
    sw x11, 0(x6)

     #iii
    lhu x12, 0x100(0)

     #iv
    lh x13, 0x1F0(0)

     #v
    lb x14, 0x1F0(0)
   
end:
    j end
