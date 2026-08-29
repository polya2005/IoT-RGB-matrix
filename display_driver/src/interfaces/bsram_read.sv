interface bsram_read_if #(
    parameter ADDR_WIDTH = 9,
    parameter DATA_WIDTH = 8
);
  logic [ADDR_WIDTH-1:0] addr;
  logic [DATA_WIDTH-1:0] data;
  logic read_enable;

  modport reader(output addr, output read_enable, input data);
  modport bsram(input addr, input read_enable, output data);
endinterface
