class spi_seq extends uvm_sequence #(spi_tran);
	`uvm_object_utils(spi_seq)

	function new(string name = "spi_seq");
		super.new(name);
	endfunction

	task body();
		spi_tran tr;
		`uvm_info(get_type_name(), "Sequence", UVM_MEDIUM)

		repeat (10) begin
			// Write random tx data;
			tr = spi_tran::type_id::create("tr");
			start_item(tr);
			assert(tr.randomize());

			#10;
			finish_item(tr);

		end
	endtask
endclass
