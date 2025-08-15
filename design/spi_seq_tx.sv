// seq: random tx_data only;
class spi_seq_tx extends uvm_sequence #(spi_tran);
	`uvm_object_utils(spi_seq_tx)
	int tb_num_seq;

	function new(string name = "spi_seq_tx");
		super.new(name);
	endfunction//new

	task body();
		spi_tran tr;
        tr = spi_tran::type_id::create("tr");
		`uvm_info(get_type_name(), "SEQ_TX", UVM_MEDIUM)
        
        // issue some basic spi transactions;
		repeat (tb_num_seq) begin
			start_item(tr);
			// we just want normal tx;
			tr.rst_n <= 1'b1;
			tr.start <= 1'b1;
			tr.tx_data <= $urandom_range(0, 2**8);
			#($urandom_range(1, 10));
			finish_item(tr);
		end
	endtask//body
endclass
