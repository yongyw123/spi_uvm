class spi_scb extends uvm_scoreboard;
	`uvm_component_utils(spi_scb)

	//////////////////////////////
	// OVERVIEW;
	//////////////////////////////
	// 1, we create three fifos to store the transaction passed from the monitor;
	// 2. the packets from the monitor are the same;
	// 3. but we direct / filter the packet into the bins (fifo) depending
	//		 on the tag/type;
	// 4. as for the checkers;
	// 		there are two groups;
	//			a. we implement the checkers directly using the written packet (without fifo);
	//				this is where we want "instantaneous" check at every system clock;
	//				also, here, we do not have to care about fifo underflow or overflow;
	//			b. we implement the checkers that check SPI protocol using the fifo;
	//				we compare the packets from the consumer fifo againts the packets
	//				from the driver fifo;
	//				
	// NOTE:
	// 1. free_fifo; 
	//		based on system clock; will overflow but DONT CARE;
	//		reason: we only use this to facilitate the protocol checking;
	//
	// 2. drv_fifo;
	//		we use the packets from the fifo when we want to check the driver end;
	//		this will not overflow;
	//		reason: we use the falling or rising sclk captured data;
	//		which is slower than the system clock;
	// 
	// 3. con_fifo:
	// 		same as drv_fifo but this is the passive monitoring packet;l
	//			

	uvm_analysis_imp #(spi_tran, spi_scb) scb_imp;
	uvm_tlm_analysis_fifo #(spi_tran) drv_fifo;
	uvm_tlm_analysis_fifo #(spi_tran) con_fifo;
	uvm_tlm_analysis_fifo #(spi_tran) free_fifo; 

	int passed_count;
  	int failed_count;

	int cnt_sysclk;
	bit last_sampled_sclk;

	int total_transactions;
	int pass_rate;
	int fail_rate;
	int test_passed;
	string test_summary;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		scb_imp = new("scb_imp", this);

		// init value;
		passed_count = 0;
		failed_count = 0;
		cnt_sysclk = 0;
		last_sampled_sclk = 0;

	endfunction//new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		drv_fifo = new("drv_fifo", this);
		con_fifo = new("con_fifo", this);
		free_fifo = new("free_fifo", this);
	endfunction//build_phase

	function void write(spi_tran tr_dut);
		//////////////////////////////
		// free-running sampling based
		// on the system clock;
		//////////////////////////////
		if(tr_dut.sample_type == "free") begin

			// store it into fifo for other tests below for convenience;
			free_fifo.try_put(tr_dut);
				
			// use the consumer type;
			if(tr_dut.tran_is_drv_type == 1'b0) begin
				/////////////////////
				// TEST 01: RESET;
				/////////////////////
				
				// ignore mosi;
				// there is no known mosi default state;
				// it could be either unknown or one
				if(tr_dut.rst_n == 1'b0) begin
					sva_t1: assert(
						(tr_dut.busy == 1'b0) &&
						(tr_dut.done == 1'b0) &&
						(tr_dut.sclk == 1'b0) &&
						(tr_dut.cs_n == 1'b1) &&
						(tr_dut.rx_data == '0)
					) begin
						passed_count++; 
						`uvm_info("SCOREBOARD", $sformatf("TEST_RESET - PASSED"), UVM_MEDIUM)
					end
						else begin
							failed_count++;
							`uvm_info("SCOREBOARD", $sformatf("TEST_RESET - FAILED"), UVM_MEDIUM)
						end
				end

				/////////////////////
				// TEST 06: SCLK DIV
				/////////////////////
				
				// to check sclk divider;
				// we check by asserting that sclk
				// must toggle for every 4 clk;
				// otherwise, sclk must not toggle;
				if(tr_dut.rst_n == 1'b1) begin
					// clear
					if(
						((tr_dut.cs_n | tr_dut.done) == 1'b1) ||
						(tr_dut.busy == 1'b0)
					) begin
						cnt_sysclk = 0;
						last_sampled_sclk = 0;
					end

					// check sclk;
					else begin
						
						cnt_sysclk++;

						`uvm_info("SCB", $sformatf("[TEST_CLKDIV] cnt_sys_clk: %0d, sclk: %0b, last_sampled_sclk: %0b", 
							cnt_sysclk,	
							tr_dut.sclk,
							last_sampled_sclk
						), 
						UVM_MEDIUM)

						// sclk must change after the forth sysclk;
						if(cnt_sysclk == 5) begin
							sva_t6a: assert(last_sampled_sclk != tr_dut.sclk)
								begin
									passed_count++; 
									`uvm_info("SCOREBOARD", $sformatf("TEST_CLKDIV - PASSED"), UVM_MEDIUM)
								end
								else begin
									failed_count++;
									`uvm_info("SCOREBOARD", $sformatf("TEST_CLKDIV - FAILED"), UVM_MEDIUM)
								end

							// update the last sample;					
							last_sampled_sclk = tr_dut.sclk;

							// wrap around to 1 because of the fifth above;
							cnt_sysclk = 1;
						end

						// sclk must not change;
						else begin
							sva_t6b: assert(last_sampled_sclk == tr_dut.sclk)
								begin
									passed_count++; 
									`uvm_info("SCOREBOARD", $sformatf("TEST_CLKDIV - PASSED"), UVM_MEDIUM)
								end
								else begin
									failed_count++;
									`uvm_info("SCOREBOARD", $sformatf("TEST_CLKDIV - FAILED"), UVM_MEDIUM)
								end
						end
					end
				end
				
				// clear
				else begin
					cnt_sysclk = 0;
					last_sampled_sclk = 0;
				end
			end// TEST_06_END	
		end

		//////////////////////////////
		// sampling based on sclk;
		//////////////////////////////
		else begin
			// driver;
			if(tr_dut.tran_is_drv_type) begin
				drv_fifo.try_put(tr_dut);
				// `uvm_info("SCB", $sformatf("[DRV_FIFO] got content;"), UVM_MEDIUM)
				
			end
			// consumer
			else begin
				con_fifo.try_put(tr_dut);
				// `uvm_info("SCB", $sformatf("[CON_FIFO] got content;"), UVM_MEDIUM)
			end
		end
	endfunction//write

	task run_phase(uvm_phase phase);
		spi_tran tr_fifo_drv;
		spi_tran tr_fifo_con;
		spi_tran tr_fifo_free;
		
		forever begin
			
			fork
				
				/////////////////////
				// THREADS;
				/////////////////////
				// 1. free_fifo;
				// 2. con_fifo;
				// 3. drv_fifo;

				begin 
					free_fifo.get(tr_fifo_free); 

					`uvm_info("SCOREBOARD", $sformatf("FIFO_FREE - received rst_n: %0b; busy: %0b, done: %0b, sclk: %0b, mosi: %0b, cs_n: %0b, rx_data: %2h, tx_data_reg: %2h", 
						tr_fifo_free.rst_n,
						tr_fifo_free.busy,
						tr_fifo_free.done,
						tr_fifo_free.sclk,
						tr_fifo_free.mosi,
						tr_fifo_free.cs_n,
						tr_fifo_free.rx_data,
						tr_fifo_free.tx_data_reg
					), UVM_MEDIUM)


					/////////////////////
					// TEST 02: IDLE
					/////////////////////
					// not reset not start;
					// if((tr_fifo_free.rst_n == 1'b1) && (tr_fifo_free.start == 1'b0))begin
					if(tr_fifo_free.rst_n == 1'b1) begin
						// if the start is de-asserted prior to any transaction, 
						// we expect the output to be in the default state;
						// otherwise, if the start is de-asserted during an ongoing 
						// transaction, then we should expect the start state
						// to be ignored;
						if((tr_fifo_free.start == 1'b1) && (tr_fifo_free.busy == 1'b0)) begin
							sva_t2a: assert(
								(tr_fifo_free.busy == 1'b0) &&
								(tr_fifo_free.done == 1'b0) &&
								(tr_fifo_free.sclk == 1'b0) &&
								(tr_fifo_free.mosi == 1'b0) &&
								(tr_fifo_free.cs_n == 1'b1) &&
								(tr_fifo_free.rx_data == '0)
							) begin
								passed_count++;
								`uvm_info("SCOREBOARD", $sformatf("TEST_IDLE - PASSED"), UVM_MEDIUM)
							end
							else begin
								failed_count++;
								`uvm_info("SCOREBOARD", $sformatf("TEST_IDLE - FAILED"), UVM_MEDIUM)
							end
						end
						else if((tr_fifo_free.start == 1'b1) && (tr_fifo_free.busy == 1'b1)) begin
							sva_t2b: assert(tr_fifo_free.cs_n == 1'b0) begin
								passed_count++;
								`uvm_info("SCOREBOARD", $sformatf("TEST_IDLE - PASSED"), UVM_MEDIUM)
							end
							else begin
								failed_count++;
								`uvm_info("SCOREBOARD", $sformatf("TEST_IDLE - FAILED"), UVM_MEDIUM)
							end
						end
					end
					
				end

				begin drv_fifo.get(tr_fifo_drv); end
				begin con_fifo.get(tr_fifo_con); end
				
			join


			`uvm_info("FIFO_CON", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2h, rx_data: %2h, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b, num_mosi_rsample: %0d, num_mosi_fsample: %0d, num_miso_rsample: %0d, num_miso_fsample: %0d, tx_data_reg: %2h, mosi_rdata_q: %p, mosi_fdata_q: %p, miso_rdata_q: %p, miso_fdata_q: %p",

				tr_fifo_con.rst_n,
					tr_fifo_con.sclk,
					tr_fifo_con.start,
					tr_fifo_con.tx_data,
					tr_fifo_con.rx_data,
					tr_fifo_con.busy,
					tr_fifo_con.done,
					tr_fifo_con.mosi,
					tr_fifo_con.miso,
					tr_fifo_con.cs_n,
					tr_fifo_con.sample_type,
					tr_fifo_con.tran_is_drv_type,
					tr_fifo_con.num_mosi_rsample,
					tr_fifo_con.num_mosi_fsample,
					tr_fifo_con.num_miso_rsample,
					tr_fifo_con.num_miso_fsample,
					tr_fifo_free.tx_data_reg,
					tr_fifo_con.mosi_rdata_q,
					tr_fifo_con.mosi_fdata_q,
					tr_fifo_con.miso_rdata_q,
					tr_fifo_con.miso_fdata_q
			), 
			UVM_MEDIUM)


			/////////////////////
			// TEST 03: TX -> MOSI
			/////////////////////
			// check order;
			// if((tr_fifo_drv.rst_n == 1'b1) && (tr_fifo_drv.start == 1'b1))begin
			// if((tr_fifo_drv.rst_n == 1'b1) && (tr_fifo_drv.cs_n == 1'b0))begin
			if((tr_fifo_drv.rst_n == 1'b1) && (tr_fifo_drv.busy == 1'b1))begin
				if(tr_fifo_con.done == 1'b1) begin
					sva_t3: assert(tr_fifo_con.mosi_rdata_q[0] == tr_fifo_free.tx_data_reg) 
					begin
						passed_count++;
						`uvm_info("SCOREBOARD", $sformatf("TEST_TX - PASSED"), UVM_MEDIUM)
					end
					else begin
						failed_count++;
						`uvm_info("SCOREBOARD", $sformatf("TEST_TX - FAILED - expected mosi_rdata_q: %p == tx_data_reg:%2h", 
							tr_fifo_con.mosi_rdata_q, tr_fifo_free.tx_data_reg), UVM_MEDIUM)
					end
				end
			end//TEST_03_END

			/////////////////////
			// TEST 04: MISO -> RX
			/////////////////////
			// check order;
			// if((tr_fifo_drv.rst_n == 1'b1) && (tr_fifo_drv.start == 1'b1))begin
			// if((tr_fifo_drv.rst_n == 1'b1) && (tr_fifo_drv.cs_n == 1'b0))begin
			if((tr_fifo_drv.rst_n == 1'b1) && (tr_fifo_drv.busy == 1'b1))begin
				if(tr_fifo_con.done == 1'b1) begin
					sva_t4: assert(tr_fifo_con.miso_fdata_q[0] == tr_fifo_con.rx_data) 
					begin
						passed_count++;
						`uvm_info("SCOREBOARD", $sformatf("TEST_RX - PASSED"), UVM_MEDIUM)
					end
					else begin
						failed_count++;
						`uvm_info("SCOREBOARD", $sformatf("TEST_RX - FAILED"), UVM_MEDIUM)
					end
				end
			end//TEST_04_END

			/////////////////////
			// TEST 05: MISO CPHA
			/////////////////////
			// check falling edge for rx_data;
			// except for all-ones or all-zeros;
			// de-serialized miso sampled at rising sclk and falling sclk should be different;
			// if((tr_fifo_drv.rst_n == 1'b1) && (tr_fifo_drv.start == 1'b1))begin
			// if((tr_fifo_drv.rst_n == 1'b1) && (tr_fifo_drv.cs_n == 1'b0))begin
			if((tr_fifo_drv.rst_n == 1'b1) && (tr_fifo_drv.busy == 1'b1))begin
				if(tr_fifo_con.done == 1'b1) begin
					if((tr_fifo_con.rx_data != '0) || (tr_fifo_con.rx_data != '1)) begin
						sva_t5: assert(tr_fifo_con.miso_rdata_q[0] != tr_fifo_con.miso_fdata_q[0]) 
						begin
							passed_count++;
							`uvm_info("SCOREBOARD", $sformatf("TEST_CPHA - PASSED"), UVM_MEDIUM)
						end
						else begin
							failed_count++;
							`uvm_info("SCOREBOARD", $sformatf("TEST_CPHA - FAILED"), UVM_MEDIUM)
						end
					end
				end
			end//TEST_05_END
		end
	endtask//run_phase

	function void extract_phase(uvm_phase phase);
		// Calculate derived metrics
		int total_transactions = passed_count + failed_count;

		if (total_transactions > 0) begin
			// real' is a casting syntax, creates a temporary real (floating-point) version of the value
			// ' is called the cast operator
			pass_rate = (real'(passed_count) / real'(total_transactions)) * 100;
			fail_rate = (real'(failed_count) / real'(total_transactions)) * 100;
		end else begin
			pass_rate = 0;
			fail_rate = 0;
		end

		// Determine overall test status
		test_passed = (failed_count == 0);  // If failed_count is 0, return true or 1, meaning test_passed is true or 1
		test_summary = test_passed ? "TEST PASSED" : "TEST FAILED";
	endfunction//extract_phase

	function void check_phase(uvm_phase phase);
		// Final verification of test results
		if (failed_count > 0) begin
			`uvm_error("CHECK", $sformatf("Scoreboard detected %0d failures", failed_count))
		end
	endfunction//check_phase

	function void report_phase(uvm_phase phase);
		`uvm_info("SCOREBOARD", "========================================", UVM_NONE)
		`uvm_info("SCOREBOARD", "SPI TEST RESULTS", UVM_NONE)
		`uvm_info("SCOREBOARD", "========================================", UVM_NONE)
		`uvm_info("SCOREBOARD", $sformatf("SPI Test Status: %s", test_summary), UVM_NONE)
		`uvm_info("SCOREBOARD", $sformatf("Pass Rate: %.2f%%", pass_rate), UVM_NONE)
		`uvm_info("SCOREBOARD", $sformatf("Passed Tran: %0d", passed_count), UVM_NONE)
		`uvm_info("SCOREBOARD", $sformatf("Failed Tran: %0d", failed_count), UVM_NONE)
	endfunction//report_phase

endclass