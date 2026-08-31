`default_nettype none `timescale 1ns / 1ps

module output_controller (
    input wire clk,
    input wire rst_n,

    bsram_read_if.reader bsram_reader_if_r[0:4],
    bsram_read_if.reader bsram_reader_if_g[0:4],
    bsram_read_if.reader bsram_reader_if_b[0:4],

    output logic matrix_sclk,
    output logic matrix_rsclk,
    output logic [4:0] matrix_ser_r,
    output logic [4:0] matrix_ser_g,
    output logic [4:0] matrix_ser_b,
    output logic [2:0] matrix_row_sel
);

  localparam COLUMN_COUNT = 40;  // The entire matrix is 40 columns wide
  localparam SUBMATRIX_HEIGHT = 8;  // Each submatrix is 8 rows tall

  typedef logic [7:0] byte_t;
  typedef logic [$clog2(SUBMATRIX_HEIGHT)-1:0] row_index_t;
  typedef logic [$clog2(COLUMN_COUNT)-1:0] column_index_t;
  byte_t subframe;
  column_index_t column_index;

  // Only pulse rsclk after the leftmost column has been shifted out
  assign matrix_rsclk = ~matrix_sclk & (column_index == COLUMN_COUNT - 1);

  genvar i;

  // Always enable reading from the SRAMs
  generate
    for (i = 0; i < 5; i = i + 1) begin
      assign bsram_reader_if_r[i].read_enable = 1'b1;
      assign bsram_reader_if_g[i].read_enable = 1'b1;
      assign bsram_reader_if_b[i].read_enable = 1'b1;
      assign bsram_reader_if_r[i].addr = {column_index, matrix_row_sel};
      assign bsram_reader_if_g[i].addr = {column_index, matrix_row_sel};
      assign bsram_reader_if_b[i].addr = {column_index, matrix_row_sel};
      assign matrix_ser_r[i] = bsram_reader_if_r[i].data > subframe;
      assign matrix_ser_g[i] = bsram_reader_if_g[i].data > subframe;
      assign matrix_ser_b[i] = bsram_reader_if_b[i].data > subframe;
    end
  endgenerate

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      matrix_sclk <= 0;
      matrix_row_sel <= 0;

      subframe <= 0;
      column_index <= COLUMN_COUNT - 1;

    end else begin
      if (!matrix_sclk) begin
        if (column_index == 0) begin
          if (matrix_row_sel == row_index_t'(SUBMATRIX_HEIGHT - 1)) begin
            matrix_row_sel <= 0;
            if (subframe == 8'hFE) begin
              subframe <= 0;
            end else begin
              subframe <= subframe + 1;
            end

          end else begin
            matrix_row_sel <= matrix_row_sel + 1;
          end

          column_index <= COLUMN_COUNT - 1;

        end else begin
          column_index <= column_index - 1;
        end
      end
    end
    matrix_sclk <= ~matrix_sclk;
  end

endmodule

`default_nettype wire
