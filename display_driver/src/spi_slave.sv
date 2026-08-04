`timescale 1ns / 1ps
module spi_slave #(
    parameter DATA_WIDTH = 8
) (
    input wire clk,  // system clock
    input wire rst_n,  // active low reset
    output logic tx_ready,  // indicates that the slave is ready to transmit data
    command_bus_if.receiver tx_cmd_bus,  // command bus interface for transmitting data to the SPI master
    command_bus_if.sender rx_cmd_bus,  // command bus interface for receiving data from the SPI master

    spi_if.slave spi  // SPI interface
);
  // CPHASE = 0, CPOL = 0: Data is sampled on the rising edge of SCLK and shifted out on the falling edge.
  // MSBFIRST

  localparam DATA_BIT_COUNTER_WIDTH = $clog2(DATA_WIDTH);


  typedef logic [DATA_BIT_COUNTER_WIDTH-1:0] data_bit_counter_t;
  typedef logic [DATA_WIDTH-1:0] data_t;

  data_bit_counter_t rx_bit_counter;
  data_bit_counter_t tx_bit_counter;
  data_t tx_data;
  logic prev_sclk, prev_cs_n;

  task reset_module();
    begin
      rx_bit_counter <= 0;
      tx_bit_counter <= 0;
      tx_data <= 0;
      tx_ready <= 1;
      rx_cmd_bus.command_valid <= 0;
    end
  endtask

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      reset_module();
      prev_sclk <= 0;
      prev_cs_n <= 1;
    end else begin
      prev_sclk <= spi.sclk;
      prev_cs_n <= spi.cs_n;

      // Transaction only occurs when CS_N is low
      if (!spi.cs_n) begin
        // Save the data to be transmitted when the command bus has valid data
        if (tx_cmd_bus.command_valid && tx_ready) begin
          tx_data  <= tx_cmd_bus.command;
          tx_ready <= 0;  // not ready to transmit until the current transaction is complete
        end

        // SCLK rising edge: sample MOSI
        if (spi.sclk && !prev_sclk) begin
          rx_cmd_bus.command <= {rx_cmd_bus.command[DATA_WIDTH-2:0], spi.mosi};
          // verilator lint_off WIDTH
          if (rx_bit_counter == DATA_WIDTH - 1) begin
          // verilator lint_on WIDTH
            rx_cmd_bus.command_valid <= 1;
            rx_bit_counter <= 0;
          end else begin
            rx_cmd_bus.command_valid <= 0;
            rx_bit_counter <= rx_bit_counter + 1;
          end
        end

        // SCLK or SS_N falling edge: shift out MISO
        if ((prev_sclk && !spi.sclk) || prev_cs_n) begin
          spi.miso <= tx_data[DATA_WIDTH-1];
          // verilator lint_off WIDTH
          if (tx_bit_counter == DATA_WIDTH - 1) begin
          // verilator lint_on WIDTH
            tx_ready <= 1;
            tx_bit_counter <= 0;
          end else begin
            tx_bit_counter <= tx_bit_counter + 1;
          end
          tx_data <= {tx_data[DATA_WIDTH-2:0], 1'b0};  // shift left
        end
      end else begin
        reset_module();  // reset the module when CS_N is high
      end

    end
  end
endmodule
