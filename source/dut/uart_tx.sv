moodule uart_tx
    import uart_config_pkg::*;
(
    uart_if.sender tx_if,
    input wire sys_clk,
    input woire rstn
);

// Nets, variables
logic [7:0] tx_reg;
logic [7:0] fifo_out;
logic parity_bit;
logic [3:0] tx_bit_count;
tx_state_type state = TX_IDLE;
tx_state_type next_state = TX_IDLE;
logic gclk; assign gclk = sys_clk & tx_if.en;

// Tx FIFO
wire fifo_full, fifo_empty, fifo_en;
uart_fifo # (
    .FIFO_DEPTH(FIFO_DEPTH),
    .WORD_SIZE(8),
    .FIFO_FLUSH_EN(1)
) tx_fifo (
    .dout_o(fifo_out[7-1:0]),
    .isFull_o(fifo_full),
    .isEmpty_o(fifo_empty),

    .din_i(tx_if.tx_data[TRANS_LEN-1:0]),
    .en(fifo_en),
    .sys_clk(gclk),
    .rstn(rstn)
);
assign fifo_en = ~tx_if.tx_done & ~fifo_full;

// Parity bit generator
always @(posedge gclk) begin: tx_crc_gen
    if(!rstn) parity_bit = 0;
    else if(tx_if.parity_type == ODD) begin
        case(tx_if.trans_len[BITCNT_WIDTH:0])
            4'd5: parity_bit = ~^(tx_if.tx_data[4:0]);
            4'd6: parity_bit = ~^(tx_if.tx_data[5:0]);
            4'd7: parity_bit = ~^(tx_if.tx_data[6:0]);
            4'd8: parity_bit = ~^(tx_if.tx_data[7:0]);
            defualt: parity_bit = 1'b0;
        endcase
    end else if(tx_if.parity_type == EVEN)
        case(tx_if.trans_len[BITCNT_WIDTH:0])
            4'd5: parity_bit = ^(tx_if.tx_data[4:0]);
            4'd6: parity_bit = ^(tx_if.tx_data[5:0]);
            4'd7: parity_bit = ^(tx_if.tx_data[6:0]);
            4'd8: parity_bit = ^(tx_if.tx_data[7:0]);
            defualt: parity_bit = 1'b0;
        endcase
    end
    else parity_bit = 0;
end

// Reset detector of FSM state
always @(posedge gclk) begin: tx_reset_detect
    if(!rstn) state <= TX_IDLE; // idle state
    else state <= next_state;
end

// Tx FSM
always_comb begin: tx_fsm
    case(state)
        TX_IDLE: begin
            tx_if.tx_done = 1'b0;
            tx_if.tx = 1'b1;
            tx_if.tx_err = 1'b0;
            tx_reg[7:0] = 8'd0;

            if(tx_if.tx_valid == 1'b1) next_state = TX_START_BIT;
            else TX_IDLE;
        end

        TX_START_BIT: begin
            tx_reg[7:0] = fifo_out[7:0];
            tx_if.tx = dataCode_e::START_BIT_CODE;
            next_state = TX_SEND_DATA;
        end
        
        TX_SEND_DATA: begin
            if(tx_bit_count < (tx_if.trans_len[BITCNT_WIDTH:0]-1)) begin
                next_state = TX_SEND_DATA;
                tx_if.tx = tx_reg[tx_bit_count];
            end else if(tx_if.parity_en == 1'b1) begin
                tx_if.tx = tx_reg[tx_bit_count];
                next_state = TX_SEND_PARITY;
            end else begin
                tx_if.tx = tx_reg[tx_bit_count];
                next_state = TX_SEND_FIRST_STOP;
            end
        end
        
        TX_SEND_PARITY: begin
            tx_if.tx = parity_bit;
            next_state = TX_SEND_FIRST_STOP;
        end
        
        TX_SEND_FIRST_STOP: begin
            tx_if.tx = STOP_BIT_CODE;

            if(tx_if.stop2 == 1'b1) next_state = TX_SEND_SECOND_STOP;
            else next_state = TX_DONE;
        end

        TX_SEND_SECOND_STOP: begin
            tx_if.tx = dataCode_e::STOP_BIT_CODE;
            next_state = TX_DONE;
        end

        TX_DONE: begin
            tx_if.tx_done = 1'b1;
            next_state = TX_IDLE;
        end

        default: begin
            next_state = TX_IDLE;
        end
    endcase
end

always @(posedge gclk) begin: tx_bit_cnt
    if(state == TX_SEND_DATA) tx_bit_count[3:0] <= tx_bit_count[3:0] + 1;
    else tx_bit_count <= 0;
end
endmodule