interface bsram_write_if #(
    parameter ADDR_WIDTH = 9,
    parameter DATA_WIDTH = 8
);
  logic [ADDR_WIDTH-1:0] addr;
  logic [DATA_WIDTH-1:0] data;
  logic write_enable;

  modport writer(output addr, output data, output write_enable);
  modport bsram(input addr, input data, input write_enable);
endinterface