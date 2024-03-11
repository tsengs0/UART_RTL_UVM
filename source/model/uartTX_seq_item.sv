// The seuqnece item consist of data fields required for generating the stmulus.
// In order to generate the stimulus, the sequence items are randomised in sequences.
// Therefore, data properties in sequence items should generally be declared as rand and 
// can have constraints defined.
class uartTX_seq_item extends uvm_sequence_item;
import uart_config_pkg::*;
`uvm_object_utils(uartTX_seq_item)

operation_mode operation_mode;
rand logic [`BAUDRATE_CONFIG_BITWIDTH-1:0] baud;
logic tx_clk;
real period;

// To limit the feasible baudrate for both design and random generator
constraint feasible_baud {
    baud inside {
        4800,
        9600,
        14400,
        19200,
        38400,
        57600
    };
}

function new(string name="transaction");
    super.new(name);
endfunction
endclass