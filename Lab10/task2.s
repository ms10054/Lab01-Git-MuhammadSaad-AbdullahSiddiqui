.text
.globl _start


_start:
    # Initialise stack pointer to top of data memory
    # (address 0x1FC = last 32-bit word in 512-byte data mem)
    li   sp, 0x1FC

    # Load memory-mapped I/O base addresses
    li   t3, 0x210          # LED register address
    li   t4, 0x350          # Switch register address
    li   t5, 0x300          # Reset button address (bit 0 = reset)

    # Initial FSM state: INPUT_WAIT
    li   t0, 0              # t0 = state (0 = INPUT_WAIT)

    # Clear LEDs on startup
    sw   zero, 0(t3)


fsm_loop:

    lw   t2, 0(t5)          # read reset register
    andi t2, t2, 1          # isolate bit 0
    bne  t2, zero, do_reset # if reset pressed -> go to reset


    beq  t0, zero, state_input_wait    # state 0 -> INPUT_WAIT
    li   t6, 1
    beq  t0, t6, state_countdown       # state 1 -> COUNTDOWN
    j    fsm_loop                      # safety: unknown state

state_input_wait:
    lw   t1, 0(t4)          # read switch value
    beq  t1, zero, fsm_loop # still zero -> keep waiting

    # Non-zero input received
    sw   t1, 0(t3)          # display switch value on LEDs

    # Transition to COUNTDOWN state
    li   t0, 1              # t0 = COUNTDOWN

    # Call countdown subroutine with initial value in a0
    mv   a0, t1             # pass count value as argument
    jal  ra, countdown_sub  # call subroutine (ra saved automatically)

    # Subroutine returned -> countdown finished
    # Return to INPUT_WAIT
    li   t0, 0              # t0 = INPUT_WAIT
    sw   zero, 0(t3)        # clear LEDs
    j    fsm_loop


state_countdown:
    j    fsm_loop


do_reset:
    li   t0, 0              # force state = INPUT_WAIT
    sw   zero, 0(t3)        # clear LEDs
    j    fsm_loop


countdown_sub:
    addi sp, sp, -20        # allocate 5 words on stack
    sw   ra,  16(sp)        # save return address
    sw   s0,  12(sp)        # save s0
    sw   s1,   8(sp)        # save s1
    sw   s2,   4(sp)        # save s2
    sw   s3,   0(sp)        # save s3

    mv   s0, a0             # s0 = counter
    li   s1, 0x210          # s1 = LED address
    li   s2, 0x300          # s2 = reset button address

countdown_loop:
    # Check for reset before each decrement
    lw   s3, 0(s2)          # read reset register
    andi s3, s3, 1          # isolate reset bit
    bne  s3, zero, countdown_reset  # reset pressed -> exit early

    # Display current counter value on LEDs
    sw   s0, 0(s1)

    # Check if counter has reached zero
    beq  s0, zero, countdown_done

    # Delay loop to make countdown visible at 10 MHz
    # Target ~0.1 second delay per step
    # 10 MHz / instructions_per_iteration ≈ iterations needed
    # Simple busy-wait: 1,000,000 iterations * ~3 cycles = ~0.3 s
    li   s3, 300000

delay_loop:
    addi s3, s3, -1
    bne  s3, zero, delay_loop

    # Decrement counter
    addi s0, s0, -1
    j    countdown_loop

countdown_reset:
    # Reset detected mid-countdown: clear LEDs and exit
    sw   zero, 0(s1)
    j    countdown_exit

countdown_done:
    # Countdown reached zero: LEDs already show 0 from the sw above
    # (no extra action needed)

countdown_exit:
    lw   s3,   0(sp)        # restore s3
    lw   s2,   4(sp)        # restore s2
    lw   s1,   8(sp)        # restore s1
    lw   s0,  12(sp)        # restore s0
    lw   ra,  16(sp)        # restore return address
    addi sp, sp, 20         # deallocate frame

    ret                     # return to caller (jalr x0, ra, 0)

