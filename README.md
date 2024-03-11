# UART_RTL_UVM

---

# Work record, 11th March, 2024
The DUT is still under maintenance.
<pre>
source/
├── dut
│   ├── uart_clk_gen.sv
│   ├── uart_fifo.v
│   ├── uart_rx.sv
│   └── uart_tx.sv
├── lib
│   ├── design_header
│   │   ├── uart_baud_config.svh
│   │   └── uart_config_pkg.sv
│   ├── interface
│   │   ├── uart_clk_if.sv
│   │   └── uart_if.sv
│   └── tb_header
│       └── uart_tb_config.svh
├── model
│   ├── sequence
│   │   ├── reset_clk_seq.sv
│   │   └── variable_baud_seq.sv
│   ├── uart_config.sv
│   ├── uart_env.sv
│   ├── uart_model.svh
│   ├── uart_scoreboard.sv
│   ├── uart_test.sv
│   ├── uartTX_agent.sv
│   ├── uartTX_driver.sv
│   ├── uartTX_monitor.sv
│   └── uartTX_seq_item.sv
└── uart_tb.sv
</pre>
