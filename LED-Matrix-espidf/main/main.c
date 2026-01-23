// Copyright (c) 2026 Boonyakorn Thanpanit
#include "matrix.h"

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

uint8_t matrix_buffer[MATRIX_HEIGHT][MATRIX_WIDTH][3] = {0};

const gpio_num_t MATRIX_SER_PINS[SUBMATRIX_PER_COL][3] = {
    {MATRIX_SER_PIN_0_R, MATRIX_SER_PIN_0_G, MATRIX_SER_PIN_0_B},
    {MATRIX_SER_PIN_1_R, MATRIX_SER_PIN_1_G, MATRIX_SER_PIN_1_B},
    {MATRIX_SER_PIN_2_R, MATRIX_SER_PIN_2_G, MATRIX_SER_PIN_2_B},
    {MATRIX_SER_PIN_3_R, MATRIX_SER_PIN_3_G, MATRIX_SER_PIN_3_B},
    {MATRIX_SER_PIN_4_R, MATRIX_SER_PIN_4_G, MATRIX_SER_PIN_4_B}};

void app_main() {
  MatrixInit();
  for (int row = 0; row < MATRIX_HEIGHT; row++) {
    for (int col = 0; col < MATRIX_WIDTH; col++) {
      matrix_buffer[row][col][0] = (row + col) % 256;  // Red
      matrix_buffer[row][col][1] = (row * 2) % 256;    // Green
      matrix_buffer[row][col][2] = (col * 3) % 256;    // Blue
    }
  }
  while (true) {
    MatrixDraw((const uint8_t***)matrix_buffer);
  }
}
