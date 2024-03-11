class uartTX_agent extends uvm_agent;
`uvm_component_utils(uartTX_agent)

function new(input string inst="uartTX_agent", uvm_component parent=null);
    super.new(inst, parent);
endfunction

uartTX_driver drv;
uvm_sequencer#(uartTX_seq_item) seqr; // A sequencer to generate data 
                                     // transaction as class objects and 
                                     // send it to the driver
uartTX_monitor mon;

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = uartTX_monitor::type_id::create("mon", this);
    drv = uartTX_driver::type_id::create("drv", this);
    seqr = uvm_sequencer#(uartTX_seq_item)::type_id::create("seqr", this);
endfunction

// To connect squencer to driver if the agent is active
virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
endfunction
endclass