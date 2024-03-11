class uart_env extends uvm_env;
`uvm_component_utils(uart_env)

uartTX_agent tx_agent;
uart_scoreboard sco;

function new(input string inst="env", uvm_component c);
    super.new(inst, c);
endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tx_agent = uartTX_agent::type_id::create("tx_agent", this);
    sco = uart_scoreboard::type_id::create("sco", this);
endfunction

virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    tx_agent.mon.send.connect(sco.recv); // To connect the monitor to scoreboard
endfunction
endclass