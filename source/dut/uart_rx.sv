// Latest revision: 10th March, 2024
// Developer: Bo-Yu Tseng
// Email: tsengs0@gamil.com
// Module name: uart_rx
// 
// # I/F
//  a) Output:
//      sys_clk: clock source to drive the underlying module
//      rstn: asynchronous reset (active LOW)
//  b) Input:
//      rx_if: Standard UART receiver's interface (Note 1)
// # Param:
//      Please refer to the package "uart_config_pkg.sv"
// # Description
//      This module is to perform the RxD function in order to receive the byte 
//      data from a connected UART transmitter, where a configurable RxD FIFO is
//      employed for data integrity.
// # Dependencies
// 	    uart_config_pkg.sv
// # Note:
//      Note 1. Please refer to the "uart_if.sv" for the I/F detail
moodule uart_rx
    import uart_config_pkg::*;
(
    uart_if.receiver rx_if,
    input logic sys_clk,
    input logic rstn
);

//-------------------------------------------
// Nets and variables
//-------------------------------------------
logic [8:0] rx_reg; // Parity bit is included
rxFIFO_word_t fifo_in;
rxFIFO_word_t fifo_out;
logic parity_bit;
logic [BITCNT_WIDTH:0] rx_bit_count;
logic [RXD_SAMPLE_RATE-1:0] sampling_cnt; // One-hot encoding counter to avoid cost of binary adder
rx_state_type state = RX_IDLE;
rx_state_type next_state = RX_IDLE;
logic gclk = sys_clk & rx_if.en;

// Internal enable signals for clock gating, etc.
logic rx_shiftReg_en; // To enable the shift register to capture the sampled data (1 bit)
//-------------------------------------------
// Rx FIFO
//-------------------------------------------
logic fifo_full, fifo_empty, fifo_en;
uart_fifo # (
    .FIFO_DEPTH(FIFO_DEPTH),
    .WORD_SIZE(RXD_FIFO_WORD_WIDTH), // [MSB:LSB]: {error flag, received 8-bit data}
    .FIFO_FLUSH_EN(1)
) rx_fifo (
    .dout_o(fifo_out),
    .isFull_o(fifo_full),
    .isEmpty_o(fifo_empty),

    .din_i(fifo_in),
    .en(fifo_en),
    .sys_clk(gclk),
    .rstn(rstn)
);
assign fifo_in.ERROR_FLAG = rx_if.rx_err;
assign fifo_in.PAYLOAD = rx_reg[7:0];

// FIFO R/W is available when UART is ready to receive the data and FIFO is not full
assign fifo_en = rx_if.rx_ready & ~fifo_full;
//-------------------------------------------
// Reset detector for Rx FSM
//-------------------------------------------
always @(posedge gclk) begin: rx_reset_detect
    if(!rstn) state <= RX_IDLE; // idle state
    else state <= next_state;
end
//-------------------------------------------
// Rx FSM
//-------------------------------------------
always_comb begin: rx_fsm
    case(state)
        RX_IDLE: begin
            rx_if.rx_ready = 1'b0;
            rx_shiftReg_en = 1'b0;
            
            // Start-bit decoding compliant with UART protocol
            if(rx_if.rx_valid && !rx_if.rx) next_state = RX_START_BIT;
            else next_state = RX_IDLE;
        end

        RX_START_BIT: begin
            // End-bit decoding compliant with UART protocol
            if(sampling_cnt[RXD_SAMPLE_TIMING-1] && rx_if.rx)
                next_state = RX_IDLE;
            else if(sampling_cnt[RXD_SAMPLE_RATE-1]) // Sampling completion of one TxD clock period
                next_state = RX_RECV_DATA;
            else
                next_state = RX_START_BIT;
        end

        RX_RECV_DATA: begin
            if(sampling_cnt[RXD_SAMPLE_TIMING-1])
                rx_shiftReg_en = 1'b1;
            else if(sampling_cnt[RXD_SAMPLE_RATE-1] && rx_bit_count==(rx_if.trans_len)) begin
                if(rx_if.parity_en) next_state = RX_RECV_PARITY;
                else next_state = RX_RECV_FIRST_STOP;
            end else
                next_state = RX_RECV_DATA;
        end

        // Note: parity check will be operated right after parity bit is received.
        //       Both operations above are performed within this FSM state
        RX_RECV_PARITY: begin
            if(sampling_cnt[RXD_SAMPLE_TIMING-1]) rx_shiftReg_en = 1'b1;
            else if(sampling_cnt[RXD_SAMPLE_RATE-1]) next_state = RX_RECV_FIRST_STOP;
            else next_state = RX_RECV_PARITY;
        end

        RX_RECV_FIRST_STOP: begin
            if(sample_cnt[RXD_SAMPLE_TIMING-1]) begin
                if(rx_if.rx != STOP_BIT_CODE) 
            end
        end
    endcase
end
//-------------------------------------------
// Shift register to capture the received 
// bit data
//-------------------------------------------
always @(posedge gclk) begin: rxd_shiftReg
    if(!rstn) rx_reg <= 0;
    else if(rx_shiftReg_en) rx_reg[8:0] <= {rx_if.rx, rx_reg{8:1}};
    else rx_reg[8:0] <= rx_reg[8:0];
end
//-------------------------------------------
// Internal signal of parity bit is prepared 
// for debugging only
//-------------------------------------------
always @(posedge gclk) begin: rx_parityBit_load
    if(!rstn) parity_bit <= 0;
    else if(parityCal_en) parity_bit<=rx_if.rx;
    else parity_bit<=0;
end
//-------------------------------------------
// Odd/Even parity check calculation
//-------------------------------------------
always_comb begin: rxd_crc_decode
    // Capturing the parity bit at sample_cnt[RXD_SAMPLE_TIMING-1],
    // and performing parity check within sample_cnt[RXD_SAMPLE_RATE-1]
    if(rx_if.parity_en && sample_cnt[RXD_SAMPLE_RATE-1]) begin 
        if(rx_if.parity_type == ODD) rx_if.rx_err <= ~^rx_reg[8:0];
        else if(rx_if.parity_type == EVEN) rx_if.rx_err <= ^rx_reg[8:0];
        else rx_if.rx_err <= 1'b0;
    end else
        rx_if.rx_err <= 1'b0; // Error notification is a pulse @ RxD clock
end
//-------------------------------------------
// Counter of received data bit
//-------------------------------------------
always @(posedge gclk) begin: rx_bit_cnt
    if(!rstn) rx_bit_count <= 0;
    else if(state == RX_RECV_DATA) rx_bit_count[BITCNT_WIDTH-1:0] <= tx_bit_count[BITCNT_WIDTH-1:0] + 1;
    else rx_bit_count <= 0;
end
endmodule
