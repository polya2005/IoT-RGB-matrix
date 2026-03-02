// Copyright (c) 2026 Boonyakorn Thanpanit
#pragma once

/*
 * Matrix dimensions
 *
 * One submatrix is defined as 8x8 LEDs. The total matrix size must be a
 * multiple of 8 in both dimensions.
 */
#define MATRIX_WIDTH 8
#define MATRIX_HEIGHT 8
#define SUBMATRIX_PER_ROW (MATRIX_WIDTH >> 3)
#define SUBMATRIX_PER_COL (MATRIX_HEIGHT >> 3)

// Pin definitions (may change later)
#define DEMUX_A0_PIN 0
// #define DEMUX_A1_PIN (DEMUX_A0_PIN + 1)
// #define DEMUX_A2_PIN (DEMUX_A0_PIN + 2)
#define DEMUX_BIT_MASK (~(7 << DEMUX_A0_PIN))
#define SRCLK_PIN 22
#define RCLK_PIN 23

#define MATRIX_SER_PIN_0_R 3
#define MATRIX_SER_PIN_0_G 4
#define MATRIX_SER_PIN_0_B 5
#define MATRIX_SER_PIN_1_R 6
#define MATRIX_SER_PIN_1_G 7
#define MATRIX_SER_PIN_1_B 8
#define MATRIX_SER_PIN_2_R 9
#define MATRIX_SER_PIN_2_G 10
#define MATRIX_SER_PIN_2_B 11
#define MATRIX_SER_PIN_3_R 12
#define MATRIX_SER_PIN_3_G 13
#define MATRIX_SER_PIN_3_B 15
#define MATRIX_SER_PIN_4_R 18
#define MATRIX_SER_PIN_4_G 19
#define MATRIX_SER_PIN_4_B 20
