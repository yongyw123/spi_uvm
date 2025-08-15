// randomize rst only;
class spi_seq_rst extends uvm_sequence #(spi_tran);
	`uvm_object_utils(spi_seq_rst)

	function new(string name = "spi_seq_rst");
		super.new(name);
	endfunction

	task body();
		spi_tran tr;
		tr = spi_tran::type_id::create("tr");
		`uvm_info(get_type_name(), "RESET Sequence", UVM_MEDIUM)
		
		// issue some basic spi transactions;
		repeat (30) begin
			start_item(tr);
			tr.rst_n <= $urandom_range(0, 1);
			tr.start <= 1'b1;
			tr.tx_data <= 8'hAB;
			#($urandom_range(1, 10));
			finish_item(tr);
		end
	endtask
endclass

