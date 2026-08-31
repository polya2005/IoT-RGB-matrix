`default_nettype none `timescale 1ns/1ps

module test_output_controller;
  logic clk;
  logic rst_n;

  bsram_read_if bsram_if_r[0:4]();
  bsram_read_if bsram_if_g[0:4]();
  bsram_read_if bsram_if_b[0:4]();

  dummy_readonly_bsram dummy_bsram_inst (
      .clk(clk),
      .rst_n(rst_n),
      .bsram_if_r(bsram_if_r),
      .bsram_if_g(bsram_if_g),
      .bsram_if_b(bsram_if_b)
  );

  output_controller output_controller_inst (
      .clk(clk),
      .rst_n(rst_n),
      .bsram_reader_if_r(bsram_if_r),
      .bsram_reader_if_g(bsram_if_g),
      .bsram_reader_if_b(bsram_if_b),
      .matrix_sclk(),
      .matrix_rsclk(),
      .matrix_ser_r(),
      .matrix_ser_g(),
      .matrix_ser_b(),
      .matrix_row_sel()
  );

  // Clock generation
  always #5 clk = ~clk;  // 100 MHz clock

  initial begin
    $dumpfile("test_output_controller.vcd");
    $dumpvars(0, test_output_controller);

    clk = 0;
    rst_n = 0;
    #20;
    rst_n = 1;

    // Run the simulation for a certain time
    #10000000;

    $finish;
  end

endmodule

`default_nettype wire