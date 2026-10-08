// Copyright (c) 2026 Boonyakorn Thanpanit
#include "driver/gptimer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "matrix.h"

uint8_t matrix_buffer[MATRIX_HEIGHT][MATRIX_WIDTH][3] = {0};

#if USE_MATRIX_BITBANG
const gpio_num_t MATRIX_SER_PINS[SUBMATRIX_PER_COL][3] = {
    {MATRIX_SER_PIN_0_R, MATRIX_SER_PIN_0_G, MATRIX_SER_PIN_0_B}};  //,
// {MATRIX_SER_PIN_1_R, MATRIX_SER_PIN_1_G, MATRIX_SER_PIN_1_B},
// {MATRIX_SER_PIN_2_R, MATRIX_SER_PIN_2_G, MATRIX_SER_PIN_2_B},
// {MATRIX_SER_PIN_3_R, MATRIX_SER_PIN_3_G, MATRIX_SER_PIN_3_B},
// {MATRIX_SER_PIN_4_R, MATRIX_SER_PIN_4_G, MATRIX_SER_PIN_4_B}};

static bool RefreshMatrixTask(gptimer_handle_t timer,
                              const gptimer_alarm_event_data_t* edata,
                              void* user_ctx) {
  MatrixDraw((const uint8_t***)matrix_buffer);
  return false;
}
#endif  // USE_MATRIX_BITBANG

void app_main() {
  MatrixInit();

#if USE_MATRIX_BITBANG
  // Create a timer to refresh the matrix at regular intervals
  gptimer_handle_t gptimer;
  gptimer_config_t timer_config = {
      .clk_src = GPTIMER_CLK_SRC_DEFAULT,
      .direction = GPTIMER_COUNT_UP,
      .resolution_hz = 1000000,  // 1 MHz resolution
  };
  ESP_ERROR_CHECK(gptimer_new_timer(&timer_config, &gptimer));

  // Configure the timer to trigger an alarm every 100 microseconds
  gptimer_alarm_config_t alarm_config = {
      .alarm_count = 100,  // Trigger every 100 microseconds
      .reload_count = 0,
      .flags.auto_reload_on_alarm = true,
  };
  ESP_ERROR_CHECK(gptimer_set_alarm_action(gptimer, &alarm_config));

  // Configure the callback for the timer alarm
  gptimer_event_callbacks_t cbs = {
      .on_alarm = RefreshMatrixTask,
  };
  ESP_ERROR_CHECK(gptimer_register_event_callbacks(gptimer, &cbs, NULL));
  ESP_ERROR_CHECK(gptimer_enable(gptimer));  // Enable the timer
  ESP_ERROR_CHECK(gptimer_start(gptimer));   // Start the timer
#endif                                       // USE_MATRIX_BITBANG

  for (int row = 0; row < MATRIX_HEIGHT; row++) {
    for (int col = 0; col < MATRIX_WIDTH; col++) {
      matrix_buffer[row][col][0] = (row + col) % 256;  // Red
      matrix_buffer[row][col][1] = (row * 2) % 256;    // Green
      matrix_buffer[row][col][2] = (col * 3) % 256;    // Blue
    }
  }

  while (1) {
    vTaskDelay(pdMS_TO_TICKS(1000));
  }
  // xTaskCreate(RefreshMatrixTask, "RefreshMatrixTask", 4096, NULL, 10, NULL);
}
