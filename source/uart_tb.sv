module uart_tb;
`include "uvm_macros.svh"
import uvm_pkg::*;
`include "uart_model.svh"

uart_clk_if clk_if();
uart_clk_gen uart_clk_gen (
    .tx_clk_o (clk_if.tx_clk),

    .baud_i    (clk_if.baud),
    .ref_clk_i (clk_if.clk),
    .rstn      (clk_if.rstn)
);

initial begin
    // To configure the component that is shared through of uvm classes,
    // i.e. the interface.
    uvm_config_db #(virtual uart_clk_if)::set(null, "*", "clk_if", clk_if);
    run_test("uart_test");
end

initial begin
    #0; clk_if.rstn <= 0;
    #200; clk_if.rstn <= 1;
end

initial begin
    #0;
    clk_if.clk <= 0;
    forever #10 clk_if.clk <= ~clk_if.clk;
end

initial begin
    $dumpfile("dut.vcd");
    $dumpvars(1, uart_tb.uart_clk_gen);
end
endmodule