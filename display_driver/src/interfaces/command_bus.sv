interface command_bus_if #(
    command_width = 8
);
  logic [command_width-1:0] command;
  logic command_valid;

  modport receiver(input command, input command_valid);
  modport sender(output command, output command_valid);
endinterface
