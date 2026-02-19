.text
.globl main

main:
    # calculate 3^3
    li x10, 3              # x10 holds base value
    li x11, 3              # x11 holds exponent value
    jal x1, power          # call power function (x1 stores return address)

    # print the result stored in x10
    addi x11, x10, 0       # move result into x11 for printing
    li x10, 1
    ecall

end:
    j end

# -----------------------------------------------------------
# power(base = x10, exp = x11)
# this function calculates base^exp using recursion
# final result is returned in x10
# -----------------------------------------------------------
power:
    addi x2, x2, -8       # create space on stack
    sw x1, 4(x2)           # save return address
    sw x10, 0(x2)          # save original base because recursion changes it

    # if exponent becomes 0, we stop recursion
    beq x11, x0, base_case

    # decrease exponent and call power again
    addi x11, x11, -1
    jal x1, power

    # when recursion returns, multiply result by original base
    lw x11, 0(x2)          # restore saved base into x11
    jal x1, mult           # call multiply helper

    # restore return address and stack pointer before returning
    lw x1, 4(x2)
    addi x2, x2, 8
    jalr x0, 0(x1)         # return to previous caller

base_case:
    # base case: any number^0 = 1
    li x10, 1

    lw x1, 4(x2)
    addi x2, x2, 8
    jalr x0, 0(x1)

# -----------------------------------------------------------
# mult(x10, x11)
# multiplies x10 and x11
# result is returned in x10
# -----------------------------------------------------------
mult:
    addi x2, x2, -4        # small stack frame for this helper
    sw x1, 0(x2)            # save return address

    mul x10, x10, x11       # multiply current result with base

    lw x1, 0(x2)
    addi x2, x2, 4
    jalr x0, 0(x1)          # return back to power
