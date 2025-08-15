// randomize start only;
class spi_seq_strt extends uvm_sequence #(spi_tran);
	`uvm_object_utils(spi_seq_strt)
	int tb_num_seq;

	function new(string name = "spi_seq_strt");
		super.new(name);
	endfunction//new

	task body();
		spi_tran tr;
		tr = spi_tran::type_id::create("tr");
		`uvm_info(get_type_name(), "SEQ_START", UVM_MEDIUM)
		
		repeat (tb_num_seq) begin
			start_item(tr);
			// we just want normal tx;
			tr.rst_n <= 1'b1;
			tr.start <= $urandom_range(0, 1);
			tr.tx_data <= 8'hAB;
			#($urandom_range(5, 17));
			finish_item(tr);
		end
	endtask//body
endclass

