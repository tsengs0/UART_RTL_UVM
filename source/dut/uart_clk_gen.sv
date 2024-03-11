// Latest revision: 9th March, 2024
// Developer: Bo-Yu Tseng
// Email: tsengs0@gamil.com
// Module name: uart_clk_gen
// 
// # I/F
//  a) Output:
//      baudrate_sel_i: baudrate selection signal formed in one-hot encoding (Note 1)
//      ref_clk_i: reference clock source to generate RxD clock and TxD clock
//      rstn: asynchronous reset (active LOW)
//  b) Input:
//      tx_clk_o: clock to drive the TxD submodule
//      rx_clk_o: clock to drive the RxD submodule (Note 2)
// # Param:
//      Please refer to the package "uart_config_pkg.sv"
// # Description
//      This module is to generate two independent clock sources to drive the
//      RxD and TxD, respectively. Their clock rates are based on the given setting
//      of baudrate and referece clock.
// # Dependencies
//      uart_baud_config.svh
// 	    uart_config_pkg.sv
// # Note:
//      Note 1. Please refer to the "uart_config_pkg.onehot_baudrate_sel" to 
//              know how to use this selection signal
//      Note 2. clock rate is set to be the double of TxD clock
module uart_clk_gen 
    import uart_config_pkg::*;
(
    output reg tx_clk_o,
    output reg rx_clk_o,

    input wire [`BAUDRATE_SEL_WIDTH-1:0] baudrate_sel_i,
    input wire ref_clk_i,
    input wire rstn
);

//-------------------------------------------
// Clock divider setup
//-------------------------------------------
reg [`BAUDRAT_CNT_WIDTH-1:0] tx_max;
reg [`BAUDRAT_CNT_WIDTH-1:0] rx_max;
reg [`BAUDRAT_CNT_WIDTH-1:0] tx_count;
reg [`BAUDRAT_CNT_WIDTH-1:0] rx_count;
always @(posedge ref_clk_i) begin: clk_div_factor
    if(!rstn) tx_max <= 0;
    else begin
        case(baudrate_sel_i[`BAUDRATE_SEL_WIDTH-1:0])
            BAUDRATE_SEL_4800  : begin
                        tx_max <= `BAUDRATE_CNT_4800;
                        rx_max <= `BAUDRATE_CNT_4800 / 2;
            end

            BAUDRATE_SEL_9600  : begin
                        tx_max <= `BAUDRATE_CNT_9600;
                        rx_max <= `BAUDRATE_CNT_9600 / 2;
            end

            BAUDRATE_SEL_14400 : begin
                        tx_max <= `BAUDRATE_CNT_14400;
                        rx_max <= `BAUDRATE_CNT_14400 / ;
            end

            BAUDRATE_SEL_19200 : begin
                        tx_max <= `BAUDRATE_CNT_19200;
                        rx_max <= `BAUDRATE_CNT_19200 / 2;
            end

            BAUDRATE_SEL_38400 : begin
                        tx_max <= `BAUDRATE_CNT_38400;
                        rx_max <= `BAUDRATE_CNT_38400 / 2;
            end

            BAUDRATE_SEL_57600 : begin
                        tx_max <= `BAUDRATE_CNT_57600;
                        rx_max <= `BAUDRATE_CNT_57600 / 2;
            end

            BAUDRATE_SEL_115200: begin
                        tx_max <= `BAUDRATE_CNT_115200;
                        rx_max <= `BAUDRATE_CNT_115200 / 2;
            end

            default: begin
                        // Default baudrate: 9600
                        tx_max <= `BAUDRATE_CNT_9600;
                        rx_max <= `BAUDRATE_CNT_9600 / 2;
            end
            endcase
    end
end
//-------------------------------------------
// TxD Clock generator
//-------------------------------------------
always @(posedge ref_clk_i) begin: tx_clk_gen
    if(!rstn) begin 
        tx_count <= 0;
        tx_clk_o <= 0;
    end
    else begin
        if(tx_count <= (tx_max-1)) begin
            tx_count <= tx_count + 1;
        end
        else begin
            tx_count <= 0;
            tx_clk_o <= ~tx_clk_o;
        end
    end
end
//-------------------------------------------
// RxD Clock generator
//-------------------------------------------
always @(posedge ref_clk_i) begin: rx_clk_gen
    if(!rstn) begin 
        rx_count <= 1'b0;
        rx_max <= 1'b0
    end
    else begin
        if(rx_count <= (rx_max-1)) begin
            rx_count <= rx_count + 1;
        end
        else begin
            rx_count <= 0;
            rx_clk_o <= ~rx_clk_o;
        end
    end
end
endmodule