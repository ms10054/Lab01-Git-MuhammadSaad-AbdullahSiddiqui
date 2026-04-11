

.equ LED_ADDR,  0x200       # write counter value here → drives LEDs
.equ SW_ADDR,   0x300       # read 16-bit switch input
.equ RST_ADDR,  0x350       # read reset button (LSB = 1 when pressed)
.equ STACK_TOP, 0x1FC       # initial stack pointer value


.text
.globl _start

_start:
    li   sp, STACK_TOP          # initialise stack pointer

    # Clear LEDs on startup (ensure clean state)
    li   t2, 0
    sw   t2, LED_ADDR(x0)


WAIT_STATE:
    lw   t0, SW_ADDR(x0)        # t0 = switch input (16-bit, zero-extended)
    beq  t0, x0, WAIT_STATE     # if sw == 0 → stay in S0

    # sw != 0 → fall through to CAPTURE


CAPTURE:
    mv   s0, t0                 # latch switch value (s0 is callee-saved)
    sw   s0, LED_ADDR(x0)       # display captured value on LEDs

    # ── Build stack frame before subroutine call ──────────────
    addi sp, sp, -8             # allocate 8 bytes on stack
    sw   ra, 4(sp)              # save return address at sp+4
    sw   s0, 0(sp)              # save s0 (latched value) at sp+0

    mv   a0, s0                 # pass initial count as argument in a0
    jal  ra, COUNTDOWN          # call COUNTDOWN subroutine

    # ── Subroutine returned → counter reached 0 ──────────────
    lw   s0, 0(sp)              # restore s0
    lw   ra, 4(sp)              # restore ra
    addi sp, sp, 8              # deallocate stack frame

    j    WAIT_STATE             # FSM returns to S0


COUNTDOWN:
COUNT_LOOP:
    sw   a0, LED_ADDR(x0)       # display current counter on LEDs

    # ── Reset check (highest priority inside loop) ────────────
    lw   t1, RST_ADDR(x0)       # read reset button
    andi t1, t1, 1              # isolate LSB (button active-high)
    bne  t1, x0, DO_RESET       # if reset pressed → handle immediately

    # ── Decrement counter ─────────────────────────────────────
    addi a0, a0, -1             # counter--
    bne  a0, x0, COUNT_LOOP     # if counter != 0 → continue loop

    # ── Counter reached 0: normal subroutine return ───────────
    ret                         # return to CAPTURE (caller unwinds frame)


DO_RESET:
    li   t2, 0
    sw   t2, LED_ADDR(x0)       # clear LEDs immediately

    # ── Unwind the stack frame pushed by CAPTURE ─────────────
    lw   s0, 0(sp)              # restore s0
    lw   ra, 4(sp)              # restore ra (not used but kept clean)
    addi sp, sp, 8              # deallocate frame → sp = STACK_TOP again

    j    WAIT_STATE             # return FSM to S0 unconditionally


