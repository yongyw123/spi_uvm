class spi_tran extends uvm_sequence_item;
	// uut packet;
	rand bit start;
	rand bit [7:0] tx_data;
	rand bit [7:0] rx_data;
	rand bit busy;
	rand bit done;

	rand bit sclk;
	rand bit mosi;
	rand bit miso;
	rand bit cs_n;

	// tb helping identifier/tag;
	int wr_idx;
	int rd_idx;

	`uvm_object_utils(spi_tran)

	function new(string name = "spi_tran");
		super.new(name);
		// initialize;
		wr_idx = 0;
		rd_idx = 0;
	endfunction
endclass
