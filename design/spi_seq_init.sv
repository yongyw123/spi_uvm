// seq: initialization;
class spi_seq_init extends uvm_sequence #(spi_tran);
	`uvm_object_utils(spi_seq_init)
	int tb_num_seq;

	function new(string name = "spi_seq_init");
		super.new(name);
	endfunction//new

	task body();
		spi_tran tr;
        tr = spi_tran::type_id::create("tr");
		`uvm_info(get_type_name(), "SEQ_INIT", UVM_MEDIUM)
        
        start_item(tr);

        // initialization;
        tr.rst_n <= 1'b0;
        tr.tx_data <= '0;
        tr.start <= 1'b0;

        // hold the reset for some random length;
        #($urandom_range(10, 33));
		finish_item(tr);
	endtask//body
endclass
