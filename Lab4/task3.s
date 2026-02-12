.text
.globl main
main:
    # Initialize array at 0x100
    li x10, 0x100          # base address
    li x5, 8
    sw x5, 0(x10)
    li x5, 2
    sw x5, 4(x10)
    li x5, 10
    sw x5, 8(x10)
    li x5, 1
    sw x5, 12(x10)
    #initial array = [8, 2, 10, 1]

    li x11, 4              # len = 4

    li x5, 0               # i = 0 

    outer_loop:
        bge x5, x11, end       # if i >= len - end
        add x6, x5, x0         # j = i

    inner_loop:
        bge x6, x11, next_i    # if j >= len - next_i

        # Load a[i] into x7
        slli x12, x5, 2         # offset_i = i * 4
        add x12, x10, x12       # addr_i = base + offset_i
        lw x7, 0(x12)           # val_i = a[i]

        # Load a[j] into x8
        slli x13, x6, 2         # offset_j = j * 4
        add x13, x10, x13       # addr_j = base + offset_j
        lw x8, 0(x13)           # val_j = a[j]

        # Compare a[i] > a[j]
        ble x7, x8, next_j

        # Swap
        sw x8, 0(x12)           # a[i] = val_j
        sw x7, 0(x13)           # a[j] = val_i


    next_j:
        addi x6, x6, 1         # j++
        j inner_loop

    next_i:
        addi x5, x5, 1         # i++
        j outer_loop


end:
    j end   #final array = [1, 2, 8, 10]               
              

