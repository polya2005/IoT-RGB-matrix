// Copyright (c) 2026 Boonyakorn Thanpanit
#include "matrix.h"

#include "driver/gpio.h"

#define NOP asm volatile("nop")
#define NOP4 \
  NOP;       \
  NOP;       \
  NOP;       \
  NOP;

#define NOP8 \
  NOP4;      \
  NOP4;

#define NOP12 \
  NOP8;       \
  NOP4;

const gpio_num_t MATRIX_SER_PINS[SUBMATRIX_PER_COL][3] = {
    {MATRIX_SER_PIN_0_R, MATRIX_SER_PIN_0_G, MATRIX_SER_PIN_0_B},
    {MATRIX_SER_PIN_1_R, MATRIX_SER_PIN_1_G, MATRIX_SER_PIN_1_B},
    {MATRIX_SER_PIN_2_R, MATRIX_SER_PIN_2_G, MATRIX_SER_PIN_2_B},
    {MATRIX_SER_PIN_3_R, MATRIX_SER_PIN_3_G, MATRIX_SER_PIN_3_B},
    {MATRIX_SER_PIN_4_R, MATRIX_SER_PIN_4_G, MATRIX_SER_PIN_4_B}};

void MatrixInit(void) {
  // Initialize GPIO pins for demultiplexer control
  gpio_set_direction(DEMUX_A0_PIN, GPIO_MODE_OUTPUT);
  gpio_set_direction(DEMUX_A1_PIN, GPIO_MODE_OUTPUT);
  gpio_set_direction(DEMUX_A2_PIN, GPIO_MODE_OUTPUT);

  // Initialize GPIO pins for serial data input
  gpio_set_direction(SRCLK_PIN, GPIO_MODE_OUTPUT);
  gpio_set_direction(RCLK_PIN, GPIO_MODE_OUTPUT);
  for (int submatrix_y = 0; submatrix_y < SUBMATRIX_PER_COL; submatrix_y++) {
    for (int i = 0; i < 3; i++) {
      gpio_set_direction(MATRIX_SER_PINS[submatrix_y][i], GPIO_MODE_OUTPUT);
    }
  }
}

void MatrixDraw(const uint8_t*** buffer) {
  for (int subframe = 0; subframe < 255; subframe++) {
    // The order of the loops might not be the most performant, but it is the
    // most straightforward to understand, especially when populating the
    // buffer.
    for (int subrow = 0; subrow < 8; subrow++) {
      // Select the subrow using the demultiplexer
      gpio_set_level(DEMUX_A0_PIN, (subrow >> 0) & 1);
      gpio_set_level(DEMUX_A1_PIN, (subrow >> 1) & 1);
      gpio_set_level(DEMUX_A2_PIN, (subrow >> 2) & 1);

      // Shift in data for all columns, starting from the last column
      for (int col = MATRIX_WIDTH - 1; col >= 0; col--) {
        for (int submatrix_y = 0; submatrix_y < SUBMATRIX_PER_COL;
             submatrix_y++) {
          // Prepare data to shift into each submatrix row
          const uint8_t* pixel = buffer[(submatrix_y << 3) | subrow][col];
          for (int i = 0; i < 3; i++) {
            gpio_set_level(MATRIX_SER_PINS[submatrix_y][i],
                           pixel[i] > subframe);
          }
        }

        NOP8;  // delay for setup time (might not be necessary, but just in
               // case)

        gpio_set_level(SRCLK_PIN, 1);  // Shift data into the shift registers
        NOP12;                         // Delay for clock high time
        gpio_set_level(SRCLK_PIN, 0);  // No need to delay for hold time, which
                                       // is less than one clock cycle
      }
      // At this point, all data for the current subrow is shifted in.
      gpio_set_level(RCLK_PIN, 1);  // Latch the shifted data to output
      NOP12;                        // Delay for latch high time
      gpio_set_level(RCLK_PIN, 0);
    }
  }
}
