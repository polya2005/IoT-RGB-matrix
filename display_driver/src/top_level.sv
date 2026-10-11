`default_nettype none `timescale 1ns / 1ps

module top_level (
    input wire clk,
    input wire rst_n,

    input  wire  sclk,
    input  wire  cs_n,
    input  wire  mosi,
    output logic miso,

    output logic matrix_sclk,
    output logic matrix_rsclk,
    output logic [4:0] matrix_ser_r,
    output logic [4:0] matrix_ser_g,
    output logic [4:0] matrix_ser_b,
    output logic [2:0] matrix_row_sel
);
  bsram_write_if bsram_writer_if_r[0:4] ();
  bsram_write_if bsram_writer_if_g[0:4] ();
  bsram_write_if bsram_writer_if_b[0:4] ();

  bsram_read_if bsram_reader_if_r[0:4] ();
  bsram_read_if bsram_reader_if_g[0:4] ();
  bsram_read_if bsram_reader_if_b[0:4] ();


  genvar i;
  generate
    for (i = 0; i < 5; i++) begin : bsram_inst_gen
      Gowin_SDPB_320_8 bsram_inst_r (
          .dout(bsram_reader_if_r[i].data),
          .clka(clk),
          .cea(bsram_reader_if_r[i].read_enable),
          .reseta(~rst_n),
          .clkb(clk),
          .ceb(bsram_writer_if_r[i].write_enable),
          .resetb(~rst_n),
          .oce(1'b1),
          .ada(bsram_reader_if_r[i].addr),
          .din(bsram_writer_if_r[i].data),
          .adb(bsram_writer_if_r[i].addr)
      );
      Gowin_SDPB_320_8 bsram_inst_g (
          .dout(bsram_reader_if_g[i].data),
          .clka(clk),
          .cea(bsram_reader_if_g[i].read_enable),
          .reseta(~rst_n),
          .clkb(clk),
          .ceb(bsram_writer_if_g[i].write_enable),
          .resetb(~rst_n),
          .oce(1'b1),
          .ada(bsram_reader_if_g[i].addr),
          .din(bsram_writer_if_g[i].data),
          .adb(bsram_writer_if_g[i].addr)
      );
      Gowin_SDPB_320_8 bsram_inst_b (
          .dout(bsram_reader_if_b[i].data),
          .clka(clk),
          .cea(bsram_reader_if_b[i].read_enable),
          .reseta(~rst_n),
          .clkb(clk),
          .ceb(bsram_writer_if_b[i].write_enable),
          .resetb(~rst_n),
          .oce(1'b1),
          .ada(bsram_reader_if_b[i].addr),
          .din(bsram_writer_if_b[i].data),
          .adb(bsram_writer_if_b[i].addr)
      );
    end
  endgenerate

  command_bus_if spi_rx_cmd_bus ();
  command_bus_if spi_tx_cmd_bus ();  // Unused for now

  spi_if spi_slave_if ();
  assign spi_slave_if.sclk = sclk;
  assign spi_slave_if.cs_n = cs_n;
  assign spi_slave_if.mosi = mosi;
  assign miso = spi_slave_if.miso;

  spi_slave spi_slave_inst (
      .clk(clk),
      .rst_n(rst_n),
      .spi(spi_slave_if),
      .tx_ready(),
      .tx_cmd_bus(spi_tx_cmd_bus),
      .rx_cmd_bus(spi_rx_cmd_bus)
  );

  spi_processor spi_processor_inst (
      .clk(clk),
      .rst_n(rst_n),
      .rx_cmd_bus(spi_rx_cmd_bus),

      .bsram_writer_if_r(bsram_writer_if_r),
      .bsram_writer_if_g(bsram_writer_if_g),
      .bsram_writer_if_b(bsram_writer_if_b)
  );

  output_controller output_controller_inst (
      .clk  (clk),
      .rst_n(rst_n),

      .bsram_reader_if_r(bsram_reader_if_r),
      .bsram_reader_if_g(bsram_reader_if_g),
      .bsram_reader_if_b(bsram_reader_if_b),

      .matrix_sclk(matrix_sclk),
      .matrix_rsclk(matrix_rsclk),
      .matrix_ser_r(matrix_ser_r),
      .matrix_ser_g(matrix_ser_g),
      .matrix_ser_b(matrix_ser_b),
      .matrix_row_sel(matrix_row_sel)
  );

endmodule

`default_nettype wire
