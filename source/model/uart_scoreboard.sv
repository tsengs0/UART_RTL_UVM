class uart_scoreboard extends uvm_scoreboard;
`uvm_component_utils(uart_scoreboard)

real count = 0;
real baudcount = 0;
uvm_analysis_imp#(uartTX_seq_item, uart_scoreboard) recv;

function new(input string inst="uart_scoreboard", uvm_component parent=null);
    super.new(inst, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
endfunction

virtual function void write(uartTX_seq_item trans_1);
    count = trans_1.period / 20;
    baudcount = count;
    `uvm_info(
        "scoreboard", 
        $sformatf("BAUD: %0d, count: %0f, bcount: %0f", 
        trans_1.baud, count, baudcount), UVM_NONE
    );

    case(trans_1.baud)
        4800: begin
            if(baudcount == 10418)
                `uvm_info("scoreboard", "TEST PASSED", UVM_NONE)
            else
                `uvm_error("scoreboard", "TEST FAILED")
        end

        9600: begin
            if(baudcount == 5210)
                `uvm_info("scoreboard", "TEST PASSED", UVM_NONE)
            else
                `uvm_error("scoreboard", "TEST FAILED")
        end

        14400: begin
            if(baudcount == 3474)
                `uvm_info("scoreboard", "TEST PASSED", UVM_NONE)
            else
                `uvm_error("scoreboard", "TEST FAILED")
        end

        19200: begin
            if(baudcount == 2606)
                `uvm_info("scoreboard", "TEST PASSED", UVM_NONE)
            else
                `uvm_error("scoreboard", "TEST FAILED")
        end

        38400: begin
            if(baudcount == 1304)
                `uvm_info("scoreboard", "TEST PASSED", UVM_NONE)
            else
                `uvm_error("scoreboard", "TEST FAILED")
        end

        57600: begin
            if(baudcount == 870)
                `uvm_info("scoreboard", "TEST PASSED", UVM_NONE)
            else
                `uvm_error("scoreboard", "TEST FAILED")
        end
    endcase
endfunction
endclass