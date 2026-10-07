# SPI Communication Specification for the FPGA-Based Display Driver

## Basic Configurations

- Most Significant Bit (MSB) first.
- Clock phase = 0 and clock polarity = 0. Data is sampled on the rising edge of SCLK and shifted out on the falling edge.
- The data are processed byte by byte, i.e., the driver considers bits 0-7 as a command and bits 8-15, 16-23, ... as data.

## Conventions Used
- Byte 0 is the command. Data start at byte 1.

## Commands
### SPI_CMD_NOP

#### Command Byte:
`8'h00`

#### Data Bytes:
None

#### Description:
When the driver receives this command, it does nothing just like the name suggests.

### SPI_CMD_SET_PIXEL

#### Command Byte:
`8'h01`

#### Data Bytes:

| Byte number | Description|
| --- | --- |
| 1 | Row number (0-39) |
| 2 | Column number (0-39) |
| 3 | Red pixel value (0-255) |
| 4 | Green pixel value (0-255) |
| 5 | Blue pixel value (0-255) |

#### Description:
This command sets the pixel at the specified row and column, both zero-based, to the given set of RGB values.

### SPI_CMD_CLEAR_SCREEN

#### Command Byte:
`8'h02`

#### Data Bytes:
None

#### Description:
This command clears the frame buffer, filling every byte with a zero. As a result, all LEDs should be turned off.

### SPI_CMD_WRITE_BUFFER

### Command Byte:
`8'h03`

#### Data Bytes:

| Byte number | Description |
| --- | --- |
| $3(40r+c)+1$ | Red pixel value (0-255) at row $r$ and column $c$ |
| $3(40r+c)+2$ | Green pixel value (0-255) at row $r$ and column $c$ |
| $3(40r+c)+3$ | Blue pixel value (0-255) at row $r$ and column $c$ |

#### Description:
This command fills the frame buffer with the specified pixel values. The pixel values are given from the top left to the right and down.
