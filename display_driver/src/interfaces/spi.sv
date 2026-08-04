interface spi_if;
  logic sclk;
  logic cs_n;
  logic mosi;
  logic miso;

  modport master(output sclk, output cs_n, output mosi, input miso);
  modport slave(input sclk, input cs_n, input mosi, output miso);
endinterface
