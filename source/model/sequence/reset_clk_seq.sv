class reset_clk_seq extends uvm_sequence#(uartTX_seq_item);
`uvm_object_utils(reset_clk_seq)

uartTX_seq_item trans_1;

function new(string name="reset_clk_seq");
    super.new(name);
endfunction

virtual task body();
    repeat(1) begin
        trans_1 = uartTX_seq_item::type_id::create("trans_1");
        start_item(trans_1);
        assert(trans_1.randomize);
        trans_1.operation_mode = reset_active;
        finish_item(trans_1);
    end
endtask
endclass