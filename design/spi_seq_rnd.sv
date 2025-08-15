// spam random: {tx_data, rst_n, start};
class spi_seq_rnd extends uvm_sequence #(spi_tran);
	`uvm_object_utils(spi_seq_rnd)
	int tb_num_seq;

	function new(string name = "spi_seq_rnd");
		super.new(name);
	endfunction//new

	task body();
		spi_tran tr;
	 	tr = spi_tran::type_id::create("tr");
		`uvm_info(get_type_name(), "SEQ_RND", UVM_MEDIUM)

		repeat (tb_num_seq) begin

			start_item(tr);
			sva_seq_rnd: assert(tr.randomize());

			#($urandom_range(0, 50));
			finish_item(tr);

		end
	endtask//body

endclass
