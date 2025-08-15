// seq: proper handshaking sequence with {start, busy, done}
class spi_seq_hs extends uvm_sequence #(spi_tran);
	`uvm_object_utils(spi_seq_hs)

	function new(string name = "spi_seq_hs");
		super.new(name);
	endfunction

	task body();
		spi_tran tr;
		spi_tran rsp;

        tr = spi_tran::type_id::create("tr");
		rsp = spi_tran::type_id::create("rso");

		`uvm_info(get_type_name(), "HS Sequence", UVM_MEDIUM)

		repeat (30) begin
			start_item(tr);

				tr.rst_n <= 1'b1;
				if(rsp.busy == 1'b0) begin
					tr.start <= 1'b1;
					tr.tx_data <= $urandom_range(0, 2**8);
				end
				else if(rsp.busy == 1'b1) begin
					tr.start <= 1'b0;
				end
				#($urandom_range(1, 10));

			finish_item(tr);

			get_response(rsp);
		end
	endtask
endclass
