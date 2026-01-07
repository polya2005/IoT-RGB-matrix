// Copyright (c) 2026 Boonyakorn Thanpanit
#ifndef MATRIX_H_
#define MATRIX_H_
#include <stdint.h>

#include "driver/gpio.h"

/*
 * Matrix dimensions
 *
 * One submatrix is defined as 8x8 LEDs. The total matrix size must be a
 * multiple of 8 in both dimensions.
 */
#define MATRIX_WIDTH 40
#define MATRIX_HEIGHT 40
#define SUBMATRIX_PER_ROW (MATRIX_WIDTH >> 3)
#define SUBMATRIX_PER_COL (MATRIX_HEIGHT >> 3)

// Pin definitions (may change later)
#define DEMUX_A0_PIN 0
#define DEMUX_A1_PIN 1
#define DEMUX_A2_PIN 2
#define SRCLK_PIN 22
#define RCLK_PIN 23

extern const gpio_num_t MATRIX_SER_PINS[SUBMATRIX_PER_COL][3];

/**
 * @brief Initializes the LED matrix hardware.
 *
 * This function sets up the necessary GPIO pins and configurations to
 * prepare the LED matrix for drawing operations.
 *
 */
void MatrixInit(void);

/**
 * @brief Draws the screen buffer to the LED matrix.
 *
 * This function takes a pointer to a 3D array representing the screen buffer
 * and renders it onto the LED matrix display.
 *
 * @param buffer A pointer to the screen buffer containing pixel data. The
 * buffer is expected to be a 3D array of uint8_t values with dimensions
 * [MATRIX_HEIGHT][MATRIX_WIDTH][3].
 *
 */
void MatrixDraw(const uint8_t*** buffer);
#endif  // MATRIX_H_
