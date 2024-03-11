class uart_test extends uvm_test;
`uvm_component_utils(uart_test)
 
uart_env env;
variable_baud_seq vbar_seq;
reset_clk_seq rstn_clk_seq;

function new(input string inst="test", uvm_component c);
  super.new(inst, c);
endfunction

virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  env = uart_env::type_id::create("env", this);
  vbar_seq = variable_baud_seq::type_id::create("vbar_seq");
  rstn_clk_seq = reset_clk_seq::type_id::create("rstn_clk_seq");
endfunction

virtual task run_phase(uvm_phase phase);
  phase.raise_objection(this);
    rstn_clk_seq.start(env.tx_agent.seqr);
    vbar_seq.start(env.tx_agent.seqr);
    #20;
  phase.drop_objection(this);
endtask
endclass