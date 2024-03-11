interface uart_if;
import uart_config_pkg::*;

logic tx, rx;
logic tx_done, rx_ready;
logic tx_err, rx_err;


logic [7:0] tx_data;
logic rx_data;
logic [BITCNT_WIDTH-1:0] trans_len; // To indicate the number of bits to be sent
parity_type_t parity_type; // 0: even; 1: odd
logic parity_en; // active HIGH
logic tx_valid, rx_valid;
logic stop2; // 2 stop bits
logic en;

modport receiver (
    output [7:0] rx_data,
    output rx_ready,
    output rx_err,

    input rx,
    input [BITCNT_WIDTH-1:0] trans_len,
    input parity_type,
    input parity_en,
    input rx_valid,
    input stop2,
    input en,
    input rx_clk
);

modport sender (
    output tx,
    output tx_done,
    output tx_err,

    input [7:0] tx_data,
    input [BITCNT_WIDTH-1:0] trans_len,
    input parity_type,
    input parity_en,
    input tx_valid,
    input stop2,
    input en
);
endinterface