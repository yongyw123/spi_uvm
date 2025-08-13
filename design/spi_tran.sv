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

	// Queue of received 8-bit data
    bit [7:0] data_q[$];
	
	// Internal shift register to accumulate bits
    bit [7:0] bit_acc;
    int bit_cnt;
	
	//////////////////////////////
	// constructor;
	//////////////////////////////
	function new(string name = "spi_tran");
		super.new(name);
		num_sample = 0;
		bit_acc = 0;
		bit_cnt = 0;
		data_q = {};
	endfunction

	//////////////////////////////
	// helper;
	//////////////////////////////
	
	// one bit pusher;
    task push_bit(input bit in_bit);
        bit_acc = {bit_acc[6:0], in_bit}; // shift left, LSB first
        bit_cnt = bit_cnt + 1;

		`uvm_info("SPI_TXN", $sformatf("[sampling: %s] PUSHED BIT: %0b, cnt: %0d, bit_acc: %8b", sample_type, in_bit, bit_cnt, bit_acc), UVM_MEDIUM)

        if (bit_cnt == 8) begin
            data_q.push_back(bit_acc);
			`uvm_info("SPI_TXN", $sformatf("[sampling: %s] Pushed byte: %8b", sample_type, bit_acc), UVM_MEDIUM)
            bit_acc = 0;
            bit_cnt = 0;
        end
	endtask

	// Clear the queue and reset internal state
    function void clear();
        data_q = {};            // clear the queue
        bit_acc = 0;
        bit_cnt = 0;
    endfunction


endclass
