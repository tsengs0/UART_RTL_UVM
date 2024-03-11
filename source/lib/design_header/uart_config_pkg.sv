package uart_config_pkg;

localparam TX_FIFO_DEPTH = 1;
localparam RX_FIFO_DEPTH = 1;
localparam BITCNT_WIDTH = 3; // Bit width of trans_len signal

// One-hot encoding of the selectable baudrate
enum {
    BAUDRATE_SEL_4800   = 0,
    BAUDRATE_SEL_9600   = 1,
    BAUDRATE_SEL_14400  = 2,
    BAUDRATE_SEL_19200  = 3,
    BAUDRATE_SEL_38400  = 4,
    BAUDRATE_SEL_57600  = 5,
    BAUDRATE_SEL_115200 = 6,
} onehot_baudrate_sel;

// Configuratoin of the receiver's sampling rate
localparam RXD_SAMPLE_RATE = 2; // Double of the TxD clock rate to sample the received data
localparam RXD_SAMPLE_TIMING = RXD_SAMPLE_RATE/2;

// Tx/Rx data code
enum logic {
    START_BIT_CODE = 1'b0,
    STOP_BIT_CODE = 1'b1
} dataCode_e;

// Parity bit types
typedef enum bit {
    EVEN = 0,
    ODD = 1
} parity_type_t;

// FSM states for Tx side
enum bit [2:0] {
    TX_IDLE = 0,
    TX_START_BIT = 1,
    TX_SEND_DATA = 2,
    TX_SEND_PARITY = 3,
    TX_SEND_FIRST_STOP = 4,
    TX_SEND_SECOND_STOP = 5,
    TX_DONE = 6
} tx_state_type;

// FSM states for Rx side
enum bit [2:0] {
    RX_IDLE = 0,
    RX_START_BIT = 1,
    RX_RECV_DATA = 2,
    RX_RECV_PARITY = 3, // Parity check is included
    RX_RECV_FIRST_STOP = 4,
    RX_RECV_SECOND_STOP = 5,
    RX_DONE = 6
} rx_state_type;
endpackage