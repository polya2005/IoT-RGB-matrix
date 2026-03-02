// Copyright (c) 2026 Boonyakorn Thanpanit
#include "matrix.h"

#include "driver/gpio.h"
#include "matrix_const_macros.h"

extern const gpio_num_t MATRIX_SER_PINS[SUBMATRIX_PER_COL][3];

#if USE_MATRIX_ASM

uint32_t MATRIX_SER_PINS_BIT[SUBMATRIX_PER_COL][3];
#else
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "soc/gpio_reg.h"

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

#define DEMUX_A1_PIN (DEMUX_A0_PIN + 1)
#define DEMUX_A2_PIN (DEMUX_A0_PIN + 2)

static uint32_t* const GPIO_OUT_REGISTER = (uint32_t*)(GPIO_OUT_REG);
#endif

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
#if USE_MATRIX_ASM
      MATRIX_SER_PINS_BIT[submatrix_y][i] = 1
                                            << MATRIX_SER_PINS[submatrix_y][i];
#endif
    }
  }
}

#if !USE_MATRIX_ASM
void MatrixDraw(const uint8_t*** buffer) {
  static uint8_t subframe = 0;
  // The order of the loops might not be the most performant, but it is the
  // most straightforward to understand, especially when populating the
  // buffer.
  for (int subrow = 0; subrow < 8; subrow++) {
    // Select the subrow using the demultiplexer
    *GPIO_OUT_REGISTER =
        (*GPIO_OUT_REGISTER & DEMUX_BIT_MASK) | (subrow << DEMUX_A0_PIN);
    // gpio_set_level(DEMUX_A0_PIN, (subrow >> 0) & 1);
    // gpio_set_level(DEMUX_A1_PIN, (subrow >> 1) & 1);
    // gpio_set_level(DEMUX_A2_PIN, (subrow >> 2) & 1);

    // uint8_t* pixel = (const uint8_t*)buffer + subrow * (MATRIX_WIDTH * 3);

    // Shift in data for all columns, starting from the last column
    for (int col = MATRIX_WIDTH - 1; col >= 0; col--) {
      for (int submatrix_y = 0; submatrix_y < SUBMATRIX_PER_COL;
           submatrix_y++) {
        // Prepare data to shift into each submatrix row
        const uint8_t* pixel =
            (const uint8_t*)buffer +
            (((submatrix_y << 3) | subrow) * MATRIX_WIDTH + col) * 3;
        for (int i = 0; i < 3; i++) {
          gpio_set_level(MATRIX_SER_PINS[submatrix_y][i], pixel[i] > subframe);
        }
      }

      // NOP8;  // delay for setup time (might not be necessary, but just in
      // case)

      gpio_set_level(SRCLK_PIN, 1);  // Shift data into the shift registers
      // NOP12;                         // Delay for clock high time
      gpio_set_level(SRCLK_PIN, 0);  // No need to delay for hold time, which
                                     // is less than one clock cycle
    }
    // At this point, all data for the current subrow is shifted in.
    gpio_set_level(RCLK_PIN, 1);  // Latch the shifted data to output
    // NOP12;                        // Delay for latch high time
    gpio_set_level(RCLK_PIN, 0);
  }
  subframe = subframe + 1;
  if (subframe == 0xff) {
    subframe = 0;
    // vTaskDelay(1);
  }
}
#endif
