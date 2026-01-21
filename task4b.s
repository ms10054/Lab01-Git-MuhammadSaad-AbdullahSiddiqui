.text
.globl main
main:
   #task 4b
   # Initialize a[] at 0x100 (bytes)
    li x20, 0x100
    li x8,  5
    sb x8,  0(x20)
    li x8, 10
    sb x8,  1(x20)
    li x8, 15
    sb x8,  2(x20)
    li x8, 20
    sb x8,  3(x20)

    # Initialize b[] at 0x200 (halfwords)
    li x21, 0x200
    li x9, 100
    sh x9, 0(x21)
    li x9, 200
    sh x9, 2(x21)
    li x9, 300
    sh x9, 4(x21)
    li x9, 400
    sh x9, 6(x21)

    # Initialize c[]
    li   x22, 0x300     

    # Iteration i=0: c[0] = a[0] + b[0]
    lb   x8, 0(x20)     
    lh   x9, 0(x21)      
    add  x10, x8, x9    
    sw   x10, 0(x22)     

    # Iteration i=1: c[1] = a[1] + b[1]
    lb   x8, 1(x20)     
    lh   x9, 2(x21)      
    add  x10, x8, x9    
    sw   x10, 4(x22)     

    # Iteration i=2: c[2] = a[2] + b[2]
    lb   x8, 2(x20)     
    lh   x9, 4(x21)     
    add  x10, x8, x9    
    sw   x10, 8(x22)     

    # Iteration i=3: c[3] = a[3] + b[3]
    lb   x8, 3(x20)      
    lh   x9, 6(x21)      
    add  x10, x8, x9   
    sw   x10, 12(x22) 

end:
    j end
