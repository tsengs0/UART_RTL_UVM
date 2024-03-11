class variable_baud_seq extends uvm_sequence#(uartTX_seq_item);
`uvm_object_utils(variable_baud_seq)

uartTX_seq_item trans_1;

function new(string name="variable_baud_seq");
    super.new(name);
endfunction

virtual task body();
    repeat(5) begin
        trans_1 = uartTX_seq_item::type_id::create("trans_1");
        start_item(trans_1);
        assert(trans_1.randomize);
        trans_1.operation_mode = random_baud;
        finish_item(trans_1);
    end
endtask
endclass