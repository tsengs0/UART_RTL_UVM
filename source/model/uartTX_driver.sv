// The major purpose of a driver is to receive the data container from sequence (via interface)
// and input to DUT.
class uartTX_driver extends uvm_driver #(uartTX_seq_item);
`uvm_component_utils(uartTX_driver);

virtual uart_clk_if clk_if;
uartTX_seq_item trans_1;

function new(input string path="driver", uvm_component parent = null);
    super.new(path, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    trans_1 = uartTX_seq_item::type_id::create("trans_1");

    if(!uvm_config_db#(virtual uart_clk_if)::get(this, "", "clk_if", clk_if))
        `uvm_error("driver", "Unable to access Interface");
endfunction

virtual task run_phase(uvm_phase phase);
    forever begin
        // This method blocks until a REQ sequence_item is available in the sequencer
        seq_item_port.get_next_item(trans_1);

        if(trans_1.operation_mode == reset_active) begin
            clk_if.rstn <= 1'b0;
            repeat(5) @(posedge clk_if.clk);
        end
        else if(trans_1.operation_mode == random_baud) begin
            `uvm_info("DRV", $sformatf("Baud: %0d", trans_1.baud), UVM_NONE);
            clk_if.rstn <= 1'b1;
            clk_if.baud <= trans_1.baud;
            @(posedge clk_if.clk);
            @(posedge clk_if.tx_clk);
            @(posedge clk_if.tx_clk);
        end
        else `uvm_info("DRV", "infinite loop", UVM_NONE);

        // The non-blocking method which completes the driver-sequencer handshake
        seq_item_port.item_done();
    end
endtask
endclass