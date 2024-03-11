interface uart_clk_if #(
    parameter BAUDRATE_CONFIG_BITWIDTH = 17
);

logic clk;
logic rstn;
logic [BAUDRATE_CONFIG_BITWIDTH-1:0] baud;
logic tx_clk;

//property tx_clk_rest_checker;
//    @(posedge clk) not(rstn) |-> (tx_clk == 1'b0);
//endproperty
//tx_clk_reset_check: assert property(tx_clk_rest_checker)
//    else $error("The TX CLK is not reset to 0 when RSTn is deasserted.");
endinterface