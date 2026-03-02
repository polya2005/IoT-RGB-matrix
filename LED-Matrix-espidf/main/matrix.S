#if USE_MATRIX_ASM
#include "matrix_const_macros.h"

    .equ     SUBROW_INIT, (7 << DEMUX_A0_PIN)
    .equ     SUBROW_INCR, -(1 << DEMUX_A0_PIN)
    .equ     LAST_PIXEL_OFFSET, (((((SUBMATRIX_PER_COL - 1) << 3) | 7) * MATRIX_WIDTH + (MATRIX_WIDTH - 1)) * 3)
    .equ     LAST_COLUMN, (MATRIX_WIDTH - 1)
    .equ     LAST_SUBMATRIX_Y, (SUBMATRIX_PER_COL - 1)
    .equ     ADDR_INCR_SUBMATRIX_Y, -(MATRIX_WIDTH * 24) // Number of bytes to skip to move to the same column in the previous submatrix row
    .equ     ADDR_INCR_ADVANCE_COLUMN, (-ADDR_INCR_SUBMATRIX_Y * SUBMATRIX_PER_COL - 3) // Number of bytes to skip to move to the next column in the last submatrix row
    .equ     MATRIX_SER_PINS_BIT_OFFSET, ((SUBMATRIX_PER_COL - 1) * 12)
    .equ     MATRIX_SER_PINS_SIZE, (SUBMATRIX_PER_COL * 12) // Number of bytes used for the SER pins bitmask for all submatrix rows
    .equ     RCLK_BIT, (1 << RCLK_PIN)
    .extern  MATRIX_SER_PINS_BIT

    .section .data
    .align   4
subframe:
    .byte    0


    .section .text
    .align   2
    .global  MatrixDraw

MatrixDraw:
    lbu      t1, subframe // Load subframe byte
    li       t0, 0x60091000 // Base address of GPIO registers
    li       t2, SUBROW_INIT // row index inside each submatrix, shifted to DEMUX_A0_PIN position
    la       a2, MATRIX_SER_PINS_BIT
    addi     a2, a2, MATRIX_SER_PINS_BIT_OFFSET
    addi     a0, a0, LAST_PIXEL_OFFSET // Point to the last pixel of the subframe
begin_subrow_loop:
    bltz     t2, end_subrow_loop // If row index < 0, end subrow

    //       Select the current subrow by setting the appropriate bits in the GPIO register
    lw       t4, 4(t0)
    andi     t4, t4, DEMUX_BIT_MASK
    or       t4, t4, t2
    sw       t4, 4(t0)

    li       t5, LAST_COLUMN // column index
begin_column_loop:
    bltz     t5, end_column_loop // If column index < 0, end column loop
    li       t6, LAST_SUBMATRIX_Y
begin_submatrix_loop:
    bltz     t6, end_submatrix_loop // If submatrix_y < 0, end submatrix loop
    lbu      a1, 0(a0) // Load the red value for this pixel
    slt      a1, t1, a1 // Compare with subframe byte to determine if the LED should be on
    addi     a1, a1, -1 // Convert to 0xFFFFFFFF for on, 0x0 for off
    lw       a3, 0(a2) // Load the 1 << pin number for this submatrix row
    xor      t4, t4, a1
    or       t4, t4, a3
    xor      t4, t4, a1

    lbu      a1, 1(a0) // Load the green value for this pixel
    slt      a1, t1, a1 // Compare with subframe byte to determine if the LED should be on
    addi     a1, a1, -1 // Convert to 0xFFFFFFFF for on, 0x0 for off
    lw       a3, 4(a2) // Load the 1 << pin number for this submatrix row
    xor      t4, t4, a1
    or       t4, t4, a3
    xor      t4, t4, a1

    lbu      a1, 2(a0) // Load the blue value for this pixel
    slt      a1, t1, a1 // Compare with subframe byte to determine if the LED should be on
    addi     a1, a1, -1 // Convert to 0xFFFFFFFF for on, 0x0 for off
    lw       a3, 8(a2) // Load the 1 << pin number for this submatrix row
    xor      t4, t4, a1
    or       t4, t4, a3
    xor      t4, t4, a1

    addi     t6, t6, -1; // Decrement submatrix_y
    addi     a0, a0, ADDR_INCR_SUBMATRIX_Y // Move to the same column in the previous submatrix row
    addi     a2, a2, -12 // Move to the next set of SER pins for the previous submatrix row
end_submatrix_loop:
    sw       t4, 0(t0) // Write the updated GPIO state to set the SER pins for this column
    li       a3, 1
    slli     a3, a3, SRCLK_PIN
    or       t4, t4, a3
    nop
    nop
    nop
    nop
    nop
    sw       t4, 0(t0) // Pulse SRCLK to shift the bits
    not      a3, a3
    and      t4, t4, a3
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    addi     t5, t5, -1 // Decrement column index
    addi     a0, a0, ADDR_INCR_ADVANCE_COLUMN // Move to the next column in the last submatrix row
    addi     a2, a2, MATRIX_SER_PINS_SIZE // Reset a2 to point to the last submatrix row's SER pins
    sw       t4, 0(t0) // Clear SRCLK after the pulse
end_column_loop:
    li       a3, RCLK_BIT
    or       t4, t4, a3
    sw       t4, 0(t0) // Pulse RCLK to latch the shifted data into the output registers
    not      t4, t4
    or       t4, t4, a3
    not      t4, t4
    addi     t2, t2, SUBROW_INCR // Decrement row index
    nop
    nop
    nop
    nop
    la       a5, subframe
    slti     a4, t1, 254
    addi     t1, t1, 1
    mul      t1, t1, a4
    sw       t4, 0(t0) // Clear RCLK after the pulse
end_subrow_loop:
    sb       t1, 0(a5) // Increment subframe byte
    ret
#endif
