class uartTX_monitor extends uvm_monitor;
`uvm_component_utils(uartTX_monitor)

uvm_analysis_port#(uartTX_seq_item) send;
uartTX_seq_item trans_1;
virtual uart_clk_if clk_if;
real ton = 0;
real toff = 0;

function new(input string inst="uartTX_monitor", uvm_component parent = null);
    super.new(inst, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send = new("send", this);

    trans_1 = uartTX_seq_item::type_id::create("trans_1");

    // To connect interface to virtual interace by using "get(*)" method
    if(!uvm_config_db#(virtual uart_clk_if)::get(this, "", "clk_if", clk_if))
        `uvm_error("uartTX_monitor", "Unable to access Interface");
endfunction

virtual task run_phase(uvm_phase phase);
    forever begin
        @(posedge clk_if.clk);
        if(!clk_if.rstn) begin
            trans_1.operation_mode = reset_active;
            ton  = 0;
            toff = 0;

            `uvm_info("MON", "SYSTEM RESET DETECTED", UVM_NONE);
            send.write(trans_1); // To send the sampled transaction packet (seq. item) 
                                 // to the scoreboard
        end
        else begin
            trans_1.baud = clk_if.baud;
            trans_1.operation_mode = random_baud;
            ton  = 0;
            toff = 0;
            @(posedge clk_if.tx_clk);
            ton = $realtime;
            @(posedge clk_if.tx_clk);
            toff = $realtime;
            trans_1.period = toff - ton;

            `uvm_info("MON", $sformatf("Baud: %0d, Period: %0f", trans_1.baud, trans_1.period), UVM_NONE);
            send.write(trans_1); // To send the sampled transaction packet (seq. item)
                                 // to the scoreboard
        end
    end
endtask
endclass