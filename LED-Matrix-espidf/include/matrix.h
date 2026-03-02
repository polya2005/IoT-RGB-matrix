// Copyright (c) 2026 Boonyakorn Thanpanit
#ifndef MATRIX_H_
#define MATRIX_H_

// #define DEBUG_MATRIX

#include <stdint.h>

#include "driver/gpio.h"
#include "matrix_const_macros.h"

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
 * @note To switch between C and assembly implementations, change the
 * USE_MATRIX_ASM macro in the CMakeLists.txt file. The assembly implementation
 * is optimized for performance, while the C implementation is easier to read
 * and modify.
 *
 */
void MatrixDraw(const uint8_t*** buffer);
#endif  // MATRIX_H_
