idf_component_register(SRCS "matrix.S" "main.c" "matrix.c"
    PRIV_REQUIRES spi_flash
    PRIV_REQUIRES esp_driver_gptimer
    PRIV_REQUIRES esp_driver_gpio
    INCLUDE_DIRS "../include")
add_compile_definitions(USE_MATRIX_BITBANG=0)
add_compile_definitions(USE_MATRIX_ASM=1)
