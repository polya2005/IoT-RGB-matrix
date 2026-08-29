`default_nettype none `timescale 1ns / 1ps

module test_dummy_readonly_bsram;

  logic clk;
  logic rst_n;

  bsram_read_if bsram_if_r[5]();
  bsram_read_if bsram_if_g[5]();
  bsram_read_if bsram_if_b[5]();

  dummy_readonly_bsram dut (
      .clk(clk),
      .rst_n(rst_n),
      .bsram_if_r(bsram_if_r),
      .bsram_if_g(bsram_if_g),
      .bsram_if_b(bsram_if_b)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100 MHz clock
  end

  integer i, j;
  initial begin
    $dumpfile("test_dummy_readonly_bsram.vcd");
    $dumpvars(0, test_dummy_readonly_bsram);
    rst_n = 0;
    #20;
    rst_n = 1;
    bsram_if_r[0].read_enable = 1;
    bsram_if_g[0].read_enable = 1;
    bsram_if_b[0].read_enable = 1;

    // Test reading from the dummy BSRAM
    for (i = 0; i < 8; i = i + 1) begin
      for (j = 0; j < 40; j = j + 1) begin
        bsram_if_r[0].addr = {j[5:0], i[2:0]};
        bsram_if_g[0].addr = {j[5:0], i[2:0]};
        bsram_if_b[0].addr = {j[5:0], i[2:0]};
        #10;  // Wait for a clock cycle
        $display("R[%0d][%0d] = %0d, G[%0d][%0d] = %0d, B[%0d][%0d] = %0d", i, j,
                 bsram_if_r[0].data, i, j, bsram_if_g[0].data, i, j, bsram_if_b[0].data);
      end
    end

    $finish;
  end

endmodule

`default_nettype wire
