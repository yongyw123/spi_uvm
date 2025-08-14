// seq: initialization;
class spi_seq_init extends uvm_sequence #(spi_tran);
	`uvm_object_utils(spi_seq_init)

	function new(string name = "spi_seq_init");
		super.new(name);
	endfunction

	task body();
		spi_tran tr;
        tr = spi_tran::type_id::create("tr");
		`uvm_info(get_type_name(), "Init Sequence", UVM_MEDIUM)
        
        start_item(tr);

        // initialization;
        tr.rst_n <= 1'b0;
        tr.tx_data <= '0;
        tr.start <= 1'b0;

        // hold the reset for some random length;
        #($urandom_range(10, 33));
		finish_item(tr);

        // // issue some basic spi transactions;
		// repeat (10) begin
		// 	start_item(tr);
		// 	tr.tx_data = $urandom_range(0, 2**8);
		// 	// assert(tr.tx_data.randomize());

		// 	#($urandom_range(1, 4));
		// 	finish_item(tr);

		// end
	endtask
endclass
