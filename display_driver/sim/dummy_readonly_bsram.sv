`default_nettype none `timescale 1ns / 1ps

module dummy_readonly_bsram (
    input wire clk,
    input wire rst_n,

    bsram_read_if.bsram bsram_if_r[0:4],
    bsram_read_if.bsram bsram_if_g[0:4],
    bsram_read_if.bsram bsram_if_b[0:4]
);
  byte dummy_data[0:7][0:39];  // 8 rows, 40 columns


  task automatic initialize_dummy_data();
    integer row, col;
    for (row = 0; row < 8; row = row + 1) begin
      for (col = 0; col < 40; col = col + 1) begin
        dummy_data[row][col] = byte'(row * 40 + col);  // Example pattern
      end
    end
  endtask

  initial begin
    initialize_dummy_data();
  end

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      initialize_dummy_data();
    end
  end

  genvar i;
  generate
    for (i = 0; i < 5; i = i + 1) begin : gen_bsram_read
      always_ff @(posedge clk) begin
        if (rst_n) begin
          if (bsram_if_r[i].read_enable) begin
            bsram_if_r[i].data <= dummy_data[bsram_if_r[i].addr[2:0]][bsram_if_r[i].addr[8:3]];
          end
          if (bsram_if_g[i].read_enable) begin
            bsram_if_g[i].data <= dummy_data[bsram_if_g[i].addr[2:0]][bsram_if_g[i].addr[8:3]];
          end
          if (bsram_if_b[i].read_enable) begin
            bsram_if_b[i].data <= dummy_data[bsram_if_b[i].addr[2:0]][bsram_if_b[i].addr[8:3]];
          end
        end
      end
    end
  endgenerate

endmodule

`default_nettype wire
