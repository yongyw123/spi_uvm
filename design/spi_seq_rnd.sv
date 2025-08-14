// spam random: {tx_data, rst_n, start};
class spi_seq_rnd extends uvm_sequence #(spi_tran);
	`uvm_object_utils(spi_seq_rnd)

	function new(string name = "spi_seq_rnd");
		super.new(name);
	endfunction

	task body();
		spi_tran tr;
	 tr = spi_tran::type_id::create("tr");
		`uvm_info(get_type_name(), "RANDOM Sequence", UVM_MEDIUM)

		repeat (50) begin

			start_item(tr);
			assert(tr.randomize());

			#($urandom_range(0, 50));
			finish_item(tr);

		end
	endtask

	// task body();
	// 	spi_tran tr;
	// 	tr = spi_tran::type_id::create("tr");
	// 	`uvm_info(get_type_name(), "RANDOM Sequence", UVM_MEDIUM)
		
	// 	// issue some basic spi transactions;
	// 	repeat (10) begin
	// 		start_item(tr);
	// 		// we just want normal tx;
	// 		tr.rst_n <= 1'b1;
	// 		tr.start <= $urandom_range(0, 1);
	// 		tr.tx_data <= $urandom_range(0, 2**8);
	// 		#($urandom_range(1, 10));
	// 		finish_item(tr);
	// 	end
	// endtask
endclass
