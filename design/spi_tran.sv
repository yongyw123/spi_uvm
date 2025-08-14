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

	// sampling type: falling vs rising sclk vs free running'
	string sample_type;

	// consumer vs driver?
	bit tran_is_drv_type;

	int num_mosi_rsample;
	int num_mosi_fsample;

	int num_miso_rsample;
	int num_miso_fsample;
	
	// tx_data is registered prior to any transaction;
	// if tx_data changes during transaction,
	// then this new tx_data will be for the next transaction;
	bit [7:0] tx_data_reg;

	// queue;
	bit [7:0] mosi_rdata_q[$];
	bit [7:0] mosi_fdata_q[$];

	bit [7:0] miso_rdata_q[$];
	bit [7:0] miso_fdata_q[$];

    bit [7:0] mosi_rbit_acc;
	bit [7:0] mosi_fbit_acc;

	bit [7:0] miso_rbit_acc;
	bit [7:0] miso_fbit_acc;

    int mosi_rbit_cnt;
	int mosi_fbit_cnt;

	int miso_rbit_cnt;
	int miso_fbit_cnt;

	//////////////////////////////
	// constructor;
	//////////////////////////////
	function new(string name = "spi_tran");
		super.new(name);
		mosi_rq_clear();
		mosi_fq_clear();
	
		miso_rq_clear();
		miso_fq_clear();
	endfunction

	//////////////////////////////
	// helper;
	//////////////////////////////
	function void mosi_rq_clear();
		mosi_rdata_q = {};
		mosi_rbit_acc = 0;
		mosi_rbit_cnt = 0;
		num_mosi_rsample = 0;
	endfunction

	function void mosi_fq_clear();
		mosi_fdata_q = {};
		mosi_fbit_acc = 0;
		mosi_fbit_cnt = 0;
		num_mosi_fsample = 0;
	endfunction

	function void miso_rq_clear();
		miso_rdata_q = {};
		miso_rbit_acc = 0;
		miso_rbit_cnt = 0;
		num_miso_rsample = 0;
	endfunction

	function void miso_fq_clear();
		miso_fdata_q = {};
		miso_fbit_acc = 0;
		miso_fbit_cnt = 0;
		num_miso_fsample = 0;
	endfunction	

    function void mosi_rpush_bit(bit b);
      
      mosi_rbit_acc = {mosi_rbit_acc[6:0], b};
      mosi_rbit_cnt++;

      $display("[%s] MOSI Pushed bit: %b -> acc = %8b, mosi_rbit_cnt = %0d", sample_type, b, mosi_rbit_acc, mosi_rbit_cnt);

      if (mosi_rbit_cnt == 8) begin
        // mosi_rdata_q.push_back(mosi_rbit_acc);
		mosi_rdata_q.insert(0, mosi_rbit_acc);
        $display(">> [%s] MOSI Pushed byte to queue: %8b", sample_type, mosi_rbit_acc);
        mosi_rbit_acc = 0;
        mosi_rbit_cnt = 0;
      end
    endfunction

	function void mosi_fpush_bit(bit b);
      
      mosi_fbit_acc = {mosi_fbit_acc[6:0], b};
      mosi_fbit_cnt++;

      $display("[%s] MOSI Pushed bit: %b -> acc = %8b, mosi_fbit_cnt = %0d", sample_type, b, mosi_fbit_acc, mosi_fbit_cnt);

      if (mosi_fbit_cnt == 8) begin
        // mosi_fdata_q.push_back(mosi_fbit_acc);
		mosi_fdata_q.insert(0, mosi_fbit_acc);
        $display(">> [%s] MOSI Pushed byte to queue: %8b", sample_type, mosi_fbit_acc);
        mosi_fbit_acc = 0;
        mosi_fbit_cnt = 0;
      end
    endfunction

	function void miso_rpush_bit(bit b);
      
      miso_rbit_acc = {miso_rbit_acc[6:0], b};
      miso_rbit_cnt++;

      $display("[%s] MISO Pushed bit: %b -> acc = %8b, miso_rbit_cnt = %0d", sample_type, b, miso_rbit_acc, miso_rbit_cnt);

      if (miso_rbit_cnt == 8) begin
        // miso_rdata_q.push_back(miso_rbit_acc);
		miso_rdata_q.insert(0, miso_rbit_acc);
        $display(">> [%s] MISO Pushed byte to queue: %8b", sample_type, miso_rbit_acc);
        miso_rbit_acc = 0;
        miso_rbit_cnt = 0;
      end
    endfunction

	function void miso_fpush_bit(bit b);
      
      miso_fbit_acc = {miso_fbit_acc[6:0], b};
      miso_fbit_cnt++;

      $display("[%s] MISO Pushed bit: %b -> acc = %8b, miso_fbit_cnt = %0d", sample_type, b, miso_fbit_acc, miso_fbit_cnt);

      if (miso_fbit_cnt == 8) begin
        // miso_fdata_q.push_back(miso_fbit_acc);
		miso_fdata_q.insert(0, miso_fbit_acc);
        $display(">> [%s] MISO Pushed byte to queue: %8b", sample_type, miso_fbit_acc);
        miso_fbit_acc = 0;
        miso_fbit_cnt = 0;
      end
    endfunction



endclass
