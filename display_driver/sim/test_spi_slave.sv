`default_nettype none `timescale 1ns / 1ps

module test_spi_slave;
  byte  test_data = 8'h5a;

  logic clk;
  logic rst_n;
  logic tx_ready;
  command_bus_if #(8) tx_cmd_bus ();
  command_bus_if #(8) rx_cmd_bus ();
  spi_if spi ();

  spi_slave #(
      .DATA_WIDTH(8)
  ) dut (
      .clk(clk),
      .rst_n(rst_n),
      .tx_ready(tx_ready),
      .tx_cmd_bus(tx_cmd_bus),
      .rx_cmd_bus(rx_cmd_bus),
      .spi(spi)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("test_spi_slave.vcd");
    $dumpvars(0, test_spi_slave);

    clk = 0;
    rst_n = 0;
    spi.master.sclk = 0;

    #20;
    rst_n = 1;

    #100;
    spi.master.cs_n = 0;
    repeat (8) begin
      spi.master.mosi = test_data[7];
      test_data = {test_data[6:0], 1'b0};
      #40;
      spi.master.sclk = 1;
      #40;
      spi.master.sclk = 0;
    end

    spi.master.cs_n = 1;
    #100;
    $finish;
  end
endmodule

`default_nettype wire
