module uart_fifo #(
    parameter FIFO_DEPTH = 1,
    parameter WORD_SIZE = 8,
    parameter FIFO_FLUSH_EN = 1 // Overall FIFO content can be flushed out by rest signal 
) (
    output wire [WORD_SIZE-1:0] dout_o,
    output wire isFull_o,
    output wire isEmpty_o,

    input wire [WORD_SIZE-1:0] din_i,
    input wire en,
    input wire sys_clk,
    input wire rstn
);

wire gclk;
assign gclk = sys_clk & en;

// FIFO
reg [WORD_SIZE-1:0] fifo_mem [0:TX_FIFO_DEPTH-1];
genvar i;
generate
    if(TX_FIFO_DEPTH == 1) begin
        if(FIFO_FLUSH_EN == 1) begin
            always @(posedge gclk) begin
                if(!rstn) fifo_mem[0] <= 0; 
                else fifo_mem[0] <= din_i[WORD_SIZE-1:0];
            end
        end else begin // FIFO cannot be reset to all-zero value
            always @(posedge gclk) fifo_mem[0] <= din_i[WORD_SIZE-1:0];
        end

        assign isFull_o = 1'bx;
        assign isEmpty_o = 1'bx;
    end else begin // FIFO depth is larger than 1
        if(FIFO_FLUSH_EN == 1) begin
            always @(posedge gclk) begin
                if(!rstn) fifo_mem[0] <= 0; 
                else fifo_mem[0] <= din_i[WORD_SIZE-1:0];
            end

            for(i=1; i<TX_FIFO_DEPTH; i=i+1) begin
                always @(posedge gclk) begin
                    if(!rstn) fifo_mem[i] <= 0;
                    else fifo_mem[i] <= fifo_mem[i-1];
                end
            end
        end else begin // FIFO cannot be reset to all-zero value
            always @(posedge gclk) fifo_mem[7:0] <= din_i[WORD_SIZE-1:0];
    
            for(i=1; i<TX_FIFO_DEPTH; i=i+1) begin
                always @(posedge gclk) fifo_mem[i] <= fifo_mem[i-1];
            end
        end

        // Write pointer of FIFO
        reg [FIFO_DEPTH-1:0] write_pointer;
        always @(posedge gclk) begin
            if(!rstn) write_pointer <= 1;
            else write_pointer[FIFO_DEPTH-1:0] <= {write_pointer[FIFO_DEPTH-2:0], 1'b0};
        end

        assign isFull_o = write_pointer[FIFO_DEPTH-1];
        assign isEmpty_o = write_pointer[0];
    end
endgenerate

assign dout_o[WORD_SIZE-1:0] = tx_fifo[TX_FIFO_DEPTH-1];
endmodule