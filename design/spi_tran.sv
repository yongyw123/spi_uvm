class spi_tran extends uvm_sequence_item;
	//////////////////////////////
	// factory registration;
	//////////////////////////////
	`uvm_object_utils(spi_tran)

	//////////////////
	// signal;
	//////////////////

	// uut packet;
	bit rst_n;
	rand bit start;
	rand bit [7:0] tx_data;
	rand bit [7:0] rx_data;
	rand bit busy;
	rand bit done;

	rand bit sclk;
	rand bit mosi;
	rand bit miso;
	rand bit cs_n;

	// sampling type: falling vs rising sclk;
	string sample_type;
	int num_sample;

	// consumer vs driver?
	bit tran_is_drv_type;

	//////////////////////////////
	// constructor;
	//////////////////////////////
	function new(string name = "spi_tran");
		super.new(name);
		num_sample = 0;
	endfunction


endclass
