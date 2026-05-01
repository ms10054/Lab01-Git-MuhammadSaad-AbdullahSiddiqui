.text
.globl main

main:
    addi x2, x0, 508        # stack pointer = 0x1FC
    addi x7, x0, 0          # x7 = 0
    sw   x7, 0x200(x0)      # clear FPGA output

wait_switch:
    lw   x5, 0x300(x0)      # read switches

    # wait here while switches are 0
    beq  x5, x0, wait_switch

got_input:
    addi x8, x5, 0          # x8 = switch value

    addi x2, x2, -8         # make stack space
    sw   x1, 4(x2)          # save return address
    sw   x8, 0(x2)          # save switch value

    addi x10, x8, 0         # x10 = countdown start value
    jal  x1, countdown      # call countdown subroutine

    lw   x8, 0(x2)          # restore x8
    lw   x1, 4(x2)          # restore return address
    addi x2, x2, 8          # restore stack pointer

    beq  x0, x0, main       # go back to main


countdown:
    sw   x10, 0x200(x0)     # display current countdown value

    lw   x6, 0x350(x0)      # read btn_rst

    # if button is not pressed, continue countdown
    beq  x6, x0, no_button

    # if button is pressed, return
    beq  x0, x0, countdown_return


no_button:
    addi x10, x10, -1       # x10 = x10 - 1

    # if x10 == 0, write final 0
    beq  x10, x0, countdown_done

    # otherwise continue countdown
    beq  x0, x0, countdown


countdown_done:
    sw   x10, 0x200(x0)     # display final 0


countdown_return:
    jalr x0, x1, 0          # return from subroutine