idf_component_register(SRCS "matrix.S" "main.c" "matrix.c"
    PRIV_REQUIRES spi_flash
    REQUIRES esp_driver_gpio
    INCLUDE_DIRS "../include")
