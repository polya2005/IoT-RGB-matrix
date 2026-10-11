`default_nettype none `timescale 1ns / 1ps

module spi_processor (
    input wire clk,
    input wire rst_n,

    command_bus_if.receiver rx_cmd_bus,
    bsram_write_if.writer   bsram_writer_if_r[0:4],
    bsram_write_if.writer   bsram_writer_if_g[0:4],
    bsram_write_if.writer   bsram_writer_if_b[0:4]
);
  // Buffer size
  localparam BUFFER_SIZE = 320;  // 320 bytes per submatrix row

  // Pixel coordinates types
  typedef logic [5:0] pixel_index_t;
  typedef struct packed {
    pixel_index_t row;
    pixel_index_t col;
  } pixel_coords_t;  // [11:0]
  typedef logic [8:0] buffer_addr_t;
  typedef logic [2:0] submatrix_index_t;
  typedef struct packed {
    submatrix_index_t submatrix;
    buffer_addr_t     addr;
  } buffer_write_info_t;  // [11:0]

  // Color channel enum
  typedef enum logic [1:0] {
    RED   = 2'd0,
    GREEN = 2'd1,
    BLUE  = 2'd2
  } color_channel_t;

  function automatic buffer_write_info_t to_buffer_write_info(pixel_coords_t coords);
    return '{submatrix: coords.row[5:3], addr: {coords.col, coords.row[2:0]}};
  endfunction : to_buffer_write_info

  `include "spi_commands.sv"
  typedef logic [7:0] spi_data_t;
  spi_data_t spi_data;
  typedef enum {
    IDLE,
    PARSE_COMMAND,
    PROCESS_COMMAND
  } spi_processor_state_t;
  spi_processor_state_t state;

  struct packed {
    spi_data_t command;
    union packed {
      struct packed {
        pixel_coords_t coords;  // [14:3]
        logic [2:0] byte_count;  // [2:0]
      } set_pixel;

      struct packed {
        buffer_addr_t addr;  // [14:6]
        logic [5:0] _padding;  // [5:0]
      } clear_screen;

      struct packed {
        pixel_coords_t cur_coords;  // [14:3]
        color_channel_t channel;  // [2:1]
        logic _padding;  // [0:0]
      } write_buffer;
    } data;
  } processing_state;

  wire buffer_write_info_t write_info = to_buffer_write_info(
      processing_state.data.write_buffer.cur_coords
  );

  task automatic write_buffer(input color_channel_t channel, input spi_data_t data);
    case (channel)
      RED: begin
        case (write_info.submatrix)
          3'd0: begin
            bsram_writer_if_r[0].addr <= write_info.addr;
            bsram_writer_if_r[0].data <= data;
            bsram_writer_if_r[0].write_enable <= 1'b1;
          end
          3'd1: begin
            bsram_writer_if_r[1].addr <= write_info.addr;
            bsram_writer_if_r[1].data <= data;
            bsram_writer_if_r[1].write_enable <= 1'b1;
          end
          3'd2: begin
            bsram_writer_if_r[2].addr <= write_info.addr;
            bsram_writer_if_r[2].data <= data;
            bsram_writer_if_r[2].write_enable <= 1'b1;
          end
          3'd3: begin
            bsram_writer_if_r[3].addr <= write_info.addr;
            bsram_writer_if_r[3].data <= data;
            bsram_writer_if_r[3].write_enable <= 1'b1;
          end
          3'd4: begin
            bsram_writer_if_r[4].addr <= write_info.addr;
            bsram_writer_if_r[4].data <= data;
            bsram_writer_if_r[4].write_enable <= 1'b1;
          end
        endcase
      end
      GREEN: begin
        case (write_info.submatrix)
          3'd0: begin
            bsram_writer_if_g[0].addr <= write_info.addr;
            bsram_writer_if_g[0].data <= data;
            bsram_writer_if_g[0].write_enable <= 1'b1;
          end
          3'd1: begin
            bsram_writer_if_g[1].addr <= write_info.addr;
            bsram_writer_if_g[1].data <= data;
            bsram_writer_if_g[1].write_enable <= 1'b1;
          end
          3'd2: begin
            bsram_writer_if_g[2].addr <= write_info.addr;
            bsram_writer_if_g[2].data <= data;
            bsram_writer_if_g[2].write_enable <= 1'b1;
          end
          3'd3: begin
            bsram_writer_if_g[3].addr <= write_info.addr;
            bsram_writer_if_g[3].data <= data;
            bsram_writer_if_g[3].write_enable <= 1'b1;
          end
          3'd4: begin
            bsram_writer_if_g[4].addr <= write_info.addr;
            bsram_writer_if_g[4].data <= data;
            bsram_writer_if_g[4].write_enable <= 1'b1;
          end
        endcase
      end
      BLUE: begin
        case (write_info.submatrix)
          3'd0: begin
            bsram_writer_if_b[0].addr <= write_info.addr;
            bsram_writer_if_b[0].data <= data;
            bsram_writer_if_b[0].write_enable <= 1'b1;
          end
          3'd1: begin
            bsram_writer_if_b[1].addr <= write_info.addr;
            bsram_writer_if_b[1].data <= data;
            bsram_writer_if_b[1].write_enable <= 1'b1;
          end
          3'd2: begin
            bsram_writer_if_b[2].addr <= write_info.addr;
            bsram_writer_if_b[2].data <= data;
            bsram_writer_if_b[2].write_enable <= 1'b1;
          end
          3'd3: begin
            bsram_writer_if_b[3].addr <= write_info.addr;
            bsram_writer_if_b[3].data <= data;
            bsram_writer_if_b[3].write_enable <= 1'b1;
          end
          3'd4: begin
            bsram_writer_if_b[4].addr <= write_info.addr;
            bsram_writer_if_b[4].data <= data;
            bsram_writer_if_b[4].write_enable <= 1'b1;
          end
        endcase
      end
    endcase
  endtask : write_buffer

  task automatic disable_rgb_writes();
    case (write_info.submatrix)
      0: begin
        bsram_writer_if_r[0].write_enable <= 1'b0;
        bsram_writer_if_g[0].write_enable <= 1'b0;
        bsram_writer_if_b[0].write_enable <= 1'b0;
      end
      1: begin
        bsram_writer_if_r[1].write_enable <= 1'b0;
        bsram_writer_if_g[1].write_enable <= 1'b0;
        bsram_writer_if_b[1].write_enable <= 1'b0;
      end
      2: begin
        bsram_writer_if_r[2].write_enable <= 1'b0;
        bsram_writer_if_g[2].write_enable <= 1'b0;
        bsram_writer_if_b[2].write_enable <= 1'b0;
      end
      3: begin
        bsram_writer_if_r[3].write_enable <= 1'b0;
        bsram_writer_if_g[3].write_enable <= 1'b0;
        bsram_writer_if_b[3].write_enable <= 1'b0;
      end
      4: begin
        bsram_writer_if_r[4].write_enable <= 1'b0;
        bsram_writer_if_g[4].write_enable <= 1'b0;
        bsram_writer_if_b[4].write_enable <= 1'b0;
      end
    endcase
  endtask : disable_rgb_writes

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      state <= IDLE;
      spi_data <= 8'h00;
    end else begin
      case (state)
        IDLE: begin
          if (rx_cmd_bus.command_valid) begin
            spi_data <= rx_cmd_bus.command;
            state <= PARSE_COMMAND;
          end
        end

        PARSE_COMMAND: begin
          case (spi_data)
            SPI_CMD_NOP: state <= IDLE;  // do nothing, go back to idle
            SPI_CMD_SET_PIXEL: begin
              state <= PROCESS_COMMAND;
              processing_state.command <= SPI_CMD_SET_PIXEL;
              processing_state.data.set_pixel <= '{
                  byte_count: 3'd0,
                  coords: '{row: 6'd0, col: 6'd0}
              };
            end
            SPI_CMD_CLEAR_SCREEN: begin
              state <= PROCESS_COMMAND;
              processing_state.command <= SPI_CMD_CLEAR_SCREEN;
              processing_state.data.clear_screen <= '{addr: 9'd0, _padding: 6'dx};
            end
            SPI_CMD_WRITE_BUFFER: begin
              state <= PROCESS_COMMAND;
              processing_state.command <= SPI_CMD_WRITE_BUFFER;
              processing_state.data.write_buffer <= '{
                  channel: RED,
                  cur_coords: '{row: 6'dx, col: 6'dx},
                  _padding: 1'bx
              };
            end
          endcase
        end

        PROCESS_COMMAND: begin
          case (processing_state.command)
            SPI_CMD_SET_PIXEL: begin
              if (rx_cmd_bus.command_valid) begin
                processing_state.data.set_pixel.byte_count <= processing_state.data.set_pixel.byte_count + 1;
                case (processing_state.data.set_pixel.byte_count)
                  3'd0: processing_state.data.set_pixel.coords.row <= rx_cmd_bus.command[5:0];

                  3'd1: processing_state.data.set_pixel.coords.col <= rx_cmd_bus.command[5:0];

                  3'd2: begin
                    write_buffer(RED, rx_cmd_bus.command);
                  end

                  3'd3: begin
                    write_buffer(GREEN, rx_cmd_bus.command);
                  end

                  3'd4: begin
                    write_buffer(BLUE, rx_cmd_bus.command);
                  end

                endcase
              end else begin
                disable_rgb_writes();
                if (processing_state.data.set_pixel.byte_count == 3'd5) begin
                  state <= IDLE;
                end
              end
            end

            SPI_CMD_CLEAR_SCREEN: begin
              if (processing_state.data.clear_screen.addr < BUFFER_SIZE) begin
                bsram_writer_if_r[0].write_enable <= 1'b1;
                bsram_writer_if_g[0].write_enable <= 1'b1;
                bsram_writer_if_b[0].write_enable <= 1'b1;
                bsram_writer_if_r[1].write_enable <= 1'b1;
                bsram_writer_if_g[1].write_enable <= 1'b1;
                bsram_writer_if_b[1].write_enable <= 1'b1;
                bsram_writer_if_r[2].write_enable <= 1'b1;
                bsram_writer_if_g[2].write_enable <= 1'b1;
                bsram_writer_if_b[2].write_enable <= 1'b1;
                bsram_writer_if_r[3].write_enable <= 1'b1;
                bsram_writer_if_g[3].write_enable <= 1'b1;
                bsram_writer_if_b[3].write_enable <= 1'b1;
                bsram_writer_if_r[4].write_enable <= 1'b1;
                bsram_writer_if_g[4].write_enable <= 1'b1;
                bsram_writer_if_b[4].write_enable <= 1'b1;

                bsram_writer_if_r[0].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_g[0].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_b[0].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_r[1].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_g[1].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_b[1].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_r[2].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_g[2].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_b[2].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_r[3].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_g[3].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_b[3].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_r[4].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_g[4].addr <= processing_state.data.clear_screen.addr;
                bsram_writer_if_b[4].addr <= processing_state.data.clear_screen.addr;

                bsram_writer_if_r[0].data <= 8'd0;
                bsram_writer_if_g[0].data <= 8'd0;
                bsram_writer_if_b[0].data <= 8'd0;
                bsram_writer_if_r[1].data <= 8'd0;
                bsram_writer_if_g[1].data <= 8'd0;
                bsram_writer_if_b[1].data <= 8'd0;
                bsram_writer_if_r[2].data <= 8'd0;
                bsram_writer_if_g[2].data <= 8'd0;
                bsram_writer_if_b[2].data <= 8'd0;
                bsram_writer_if_r[3].data <= 8'd0;
                bsram_writer_if_g[3].data <= 8'd0;
                bsram_writer_if_b[3].data <= 8'd0;
                bsram_writer_if_r[4].data <= 8'd0;
                bsram_writer_if_g[4].data <= 8'd0;
                bsram_writer_if_b[4].data <= 8'd0;
                processing_state.data.clear_screen.addr <= processing_state.data.clear_screen.addr + 1;

              end else begin
                bsram_writer_if_r[0].write_enable <= 1'b0;
                bsram_writer_if_g[0].write_enable <= 1'b0;
                bsram_writer_if_b[0].write_enable <= 1'b0;
                bsram_writer_if_r[1].write_enable <= 1'b0;
                bsram_writer_if_g[1].write_enable <= 1'b0;
                bsram_writer_if_b[1].write_enable <= 1'b0;
                bsram_writer_if_r[2].write_enable <= 1'b0;
                bsram_writer_if_g[2].write_enable <= 1'b0;
                bsram_writer_if_b[2].write_enable <= 1'b0;
                bsram_writer_if_r[3].write_enable <= 1'b0;
                bsram_writer_if_g[3].write_enable <= 1'b0;
                bsram_writer_if_b[3].write_enable <= 1'b0;
                bsram_writer_if_r[4].write_enable <= 1'b0;
                bsram_writer_if_g[4].write_enable <= 1'b0;
                bsram_writer_if_b[4].write_enable <= 1'b0;
                state <= IDLE;
              end
            end

            SPI_CMD_WRITE_BUFFER: begin
              if (rx_cmd_bus.command_valid) begin
                case (processing_state.data.write_buffer.channel)
                  RED: begin
                    write_buffer(RED, rx_cmd_bus.command);
                    processing_state.data.write_buffer.channel <= GREEN;
                  end

                  GREEN: begin
                    write_buffer(GREEN, rx_cmd_bus.command);
                    processing_state.data.write_buffer.channel <= BLUE;
                  end

                  BLUE: begin
                    write_buffer(BLUE, rx_cmd_bus.command);

                    // Move to next pixel
                    if (processing_state.data.write_buffer.cur_coords.col < 6'd39) begin
                      processing_state.data.write_buffer.cur_coords.col <= processing_state.data.write_buffer.cur_coords.col + 1;
                      processing_state.data.write_buffer.channel <= RED;  // Reset channel to RED for next pixel

                    end else if (processing_state.data.write_buffer.cur_coords.row < 6'd39) begin
                      processing_state.data.write_buffer.cur_coords.col <= 6'd0;  // Reset column to 0
                      processing_state.data.write_buffer.cur_coords.row <= processing_state.data.write_buffer.cur_coords.row + 1;  // Move to next row
                      processing_state.data.write_buffer.channel <= RED;  // Reset channel to RED for next pixel

                    end else begin
                      bsram_writer_if_r[0].write_enable <= 1'b0;
                      bsram_writer_if_g[0].write_enable <= 1'b0;
                      bsram_writer_if_b[0].write_enable <= 1'b0;
                      bsram_writer_if_r[1].write_enable <= 1'b0;
                      bsram_writer_if_g[1].write_enable <= 1'b0;
                      bsram_writer_if_b[1].write_enable <= 1'b0;
                      bsram_writer_if_r[2].write_enable <= 1'b0;
                      bsram_writer_if_g[2].write_enable <= 1'b0;
                      bsram_writer_if_b[2].write_enable <= 1'b0;
                      bsram_writer_if_r[3].write_enable <= 1'b0;
                      bsram_writer_if_g[3].write_enable <= 1'b0;
                      bsram_writer_if_b[3].write_enable <= 1'b0;
                      bsram_writer_if_r[4].write_enable <= 1'b0;
                      bsram_writer_if_g[4].write_enable <= 1'b0;
                      bsram_writer_if_b[4].write_enable <= 1'b0;
                      state <= IDLE;  // Finished writing buffer, go back to IDLE

                    end
                  end
                endcase
              end
            end
          endcase
        end
      endcase
    end
  end

endmodule

`default_nettype wire
