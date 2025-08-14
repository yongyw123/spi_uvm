class spi_scb extends uvm_scoreboard;
	`uvm_component_utils(spi_scb)

	uvm_analysis_imp #(spi_tran, spi_scb) scb_imp;
	uvm_tlm_analysis_fifo #(spi_tran) drv_fifo;
	uvm_tlm_analysis_fifo #(spi_tran) con_fifo;
	uvm_tlm_analysis_fifo #(spi_tran) free_fifo; 

	int passed_count;
  	int failed_count;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		scb_imp = new("scb_imp", this);
		passed_count = 0;
		failed_count = 0;

	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		drv_fifo = new("drv_fifo", this);
		con_fifo = new("con_fifo", this);
		free_fifo = new("free_fifo", this);
	endfunction

	function void write(spi_tran tr_dut);
		// free-running sampling based
		// on the system clock;
		if(tr_dut.sample_type == "free") begin
			free_fifo.try_put(tr_dut);
			`uvm_info("SCB", $sformatf("[FREE_FIFO] got content - done: %0b", tr_dut.done), UVM_MEDIUM)
			
		end
		// sampling based on sclk;
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
	endfunction

	task run_phase(uvm_phase phase);
		spi_tran tr_fifo_drv;
		spi_tran tr_fifo_con;
		spi_tran tr_fifo_free;
		
		forever begin
			fork
				begin drv_fifo.get(tr_fifo_drv); end
				begin con_fifo.get(tr_fifo_con); end
				begin free_fifo.get(tr_fifo_free); end
			join

			/////////////////////
			// TEST 01: RESET;
			/////////////////////
			if(tr_fifo_free.rst_n == 1'b0) begin
				sva_t1: assert(
					(tr_fifo_free.busy == 1'b0) &&
					(tr_fifo_free.done == 1'b0) &&
					(tr_fifo_free.sclk == 1'b0) &&
					(tr_fifo_free.mosi == 1'b0) &&
					(tr_fifo_free.cs_n == 1'b1) &&
					(tr_fifo_free.rx_data == '0)
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
			// TEST 02: IDLE
			/////////////////////
			// not reset not start;
			if((tr_fifo_free.rst_n == 1'b1) && (tr_fifo_free.start == 1'b0))begin
				sva_t2: assert(
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

			/////////////////////
			// TEST 03: TX -> MOSI
			/////////////////////
			// check order;
			if((tr_fifo_con.rst_n == 1'b1) && (tr_fifo_con.start == 1'b1))begin
				if(tr_fifo_con.done == 1'b1) begin
					sva_t3: assert(tr_fifo_con.mosi_rdata_q[0] == tr_fifo_free.tx_data_reg) 
					begin
						passed_count++;
						`uvm_info("SCOREBOARD", $sformatf("TEST_TX - PASSED"), UVM_MEDIUM)
					end
					else begin
						failed_count++;
						`uvm_info("SCOREBOARD", $sformatf("TEST_TX - FAILED"), UVM_MEDIUM)
					end
				end
			end

			/////////////////////
			// TEST 04: MISO -> RX
			/////////////////////
			// check order;
			if((tr_fifo_con.rst_n == 1'b1) && (tr_fifo_con.start == 1'b1))begin
				if(tr_fifo_con.done == 1'b1) begin
					sva_t4: assert(tr_fifo_con.miso_rdata_q[0] == tr_fifo_con.rx_data) 
					begin
						passed_count++;
						`uvm_info("SCOREBOARD", $sformatf("TEST_RX - PASSED"), UVM_MEDIUM)
					end
					else begin
						failed_count++;
						`uvm_info("SCOREBOARD", $sformatf("TEST_RX - FAILED"), UVM_MEDIUM)
					end
				end
			end

			/////////////////////
			// TEST 05: MISO CPHA
			/////////////////////
			// check falling edge for rx_data;
			// except for all-ones or all-zeros;
			// de-serialized miso sampled at rising sclk and falling sclk should be different;
			if((tr_fifo_con.rst_n == 1'b1) && (tr_fifo_con.start == 1'b1))begin
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
			end




			// `uvm_info("IN_FIFO", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b, num_mosi_rsample: %0d, num_mosi_fsample: %0d, num_miso_rsample: %0d, num_miso_fsample: %0d, tx_data_reg: %8b, mosi_rdata_q: %8b, mosi_fdata_q: %8b, miso_rdata_q: %8b, miso_fdata_q: %8b",
			`uvm_info("IN_FIFO", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2h, rx_data: %2h, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b, num_mosi_rsample: %0d, num_mosi_fsample: %0d, num_miso_rsample: %0d, num_miso_fsample: %0d, tx_data_reg: %2h, mosi_rdata_q: %p, mosi_fdata_q: %p, miso_rdata_q: %p, miso_fdata_q: %p",

		tr_fifo_con.rst_n,
			tr_fifo_con.sclk,
			tr_fifo_con.start,
			tr_fifo_con.tx_data,
			tr_fifo_free.rx_data,
			tr_fifo_con.busy,
			tr_fifo_free.done,
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


		end

		

		// if((tr_fifo_con.rst_n == 1'b1) && (tr_fifo_con.start == 1'b1))begin
		// 	if(tr_fifo_con.num_mosi_rsample > 0) begin
		// 		sva_t3: assert(tr_fifo_con.mosi == tr_fifo_free.tx_data_reg[8-(tr_fifo_con.num_mosi_rsample)]) begin
		// 			`uvm_info("SCOREBOARD", $sformatf("TEST_TX - PASSED"), UVM_MEDIUM)
		// 			passed_count++;
		// 		end
		// 			else begin
		// 				failed_count++;
		// 				`uvm_info("SCOREBOARD", $sformatf("TEST_TX - FAILED: [num_mosi_rsample: %0d; idx: %0d] expected mosi to be %0b but observed %0b", 
		// 					tr_fifo_con.num_mosi_rsample, 
		// 					8-(tr_fifo_con.num_mosi_rsample),
		// 					tr_fifo_free.tx_data_reg[8-(tr_fifo_con.num_mosi_rsample)], 
		// 					tr_fifo_con.mosi), 
		// 				UVM_MEDIUM)
		// 			end
		// 	end
		// end


		
		// fork
		// 	forever begin 
		// 		drv_fifo.get(tr_fifo_drv); 
		// 		`uvm_info("OUT_FIFO", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b, num_rsample: %0d",
		// 				tr_fifo_drv.rst_n,
		// 					tr_fifo_drv.sclk,
		// 					tr_fifo_drv.start,
		// 					tr_fifo_drv.tx_data,
		// 					tr_fifo_drv.rx_data,
		// 					tr_fifo_drv.busy,
		// 					tr_fifo_drv.done,
		// 					tr_fifo_drv.mosi,
		// 					tr_fifo_drv.miso,
		// 					tr_fifo_drv.cs_n,
		// 					tr_fifo_drv.sample_type,
		// 					tr_fifo_drv.tran_is_drv_type,
		// 					tr_fifo_drv.num_rsample
		// 			), 
		// 			UVM_MEDIUM)
		// 	end 
		// 	forever begin 
		// 		con_fifo.get(tr_fifo_con); 
		// 		`uvm_info("IN_FIFO", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b, num_rsample: %0d",
		// 				tr_fifo_con.rst_n,
		// 					tr_fifo_con.sclk,
		// 					tr_fifo_con.start,
		// 					tr_fifo_con.tx_data,
		// 					tr_fifo_con.rx_data,
		// 					tr_fifo_con.busy,
		// 					tr_fifo_con.done,
		// 					tr_fifo_con.mosi,
		// 					tr_fifo_con.miso,
		// 					tr_fifo_con.cs_n,
		// 					tr_fifo_con.sample_type,
		// 					tr_fifo_con.tran_is_drv_type,
		// 					tr_fifo_con.num_rsample
		// 			), 
		// 			UVM_MEDIUM)
		// 	end			
		// join
	
	endtask

endclass


// fork
// 			forever begin 
// 				drv_fifo.get(tr_fifo_drv); 
// 				`uvm_info("OUT_FIFO", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b, num_rsample: %0d",
// 						tr_fifo_drv.rst_n,
// 							tr_fifo_drv.sclk,
// 							tr_fifo_drv.start,
// 							tr_fifo_drv.tx_data,
// 							tr_fifo_drv.rx_data,
// 							tr_fifo_drv.busy,
// 							tr_fifo_drv.done,
// 							tr_fifo_drv.mosi,
// 							tr_fifo_drv.miso,
// 							tr_fifo_drv.cs_n,
// 							tr_fifo_drv.sample_type,
// 							tr_fifo_drv.tran_is_drv_type,
// 							tr_fifo_drv.num_rsample
// 					), 
// 					UVM_MEDIUM)
// 			end 
// 			forever begin 
// 				con_fifo.get(tr_fifo_con); 
// 				`uvm_info("IN_FIFO", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b, num_rsample: %0d",
// 						tr_fifo_con.rst_n,
// 							tr_fifo_con.sclk,
// 							tr_fifo_con.start,
// 							tr_fifo_con.tx_data,
// 							tr_fifo_con.rx_data,
// 							tr_fifo_con.busy,
// 							tr_fifo_con.done,
// 							tr_fifo_con.mosi,
// 							tr_fifo_con.miso,
// 							tr_fifo_con.cs_n,
// 							tr_fifo_con.sample_type,
// 							tr_fifo_con.tran_is_drv_type,
// 							tr_fifo_con.num_rsample
// 					), 
// 					UVM_MEDIUM)
// 			end			
// 		join
	


			// /////////////////////
			// // TEST 03: TX;
			// /////////////////////
			// // check order;
			// if((tr_fifo_con.rst_n == 1'b1) && (tr_fifo_con.start == 1'b1))begin
			// 	if(tr_fifo_con.num_rsample > 0) begin
			// 		sva_t3: assert(tr_fifo_con.mosi == tr_fifo_con.tx_data[8-(tr_fifo_con.num_rsample)])
			// 			else begin
			// 				`uvm_info("SCOREBOARD", $sformatf("TEST TX - FAILED: [num_rsample: %0d; idx: %0d] expected mosi to be %0b but observed %0b", 
			// 					tr_fifo_con.num_rsample, 
			// 					8-(tr_fifo_con.num_rsample),
			// 					tr_fifo_con.tx_data[8-(tr_fifo_con.num_rsample)], 
			// 					tr_fifo_con.mosi), 
			// 				UVM_MEDIUM)

			// 				`uvm_info("OUT_FIFO", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b, num_rsample: %0d",
			// 					tr_fifo_drv.rst_n,
			// 						tr_fifo_drv.sclk,
			// 						tr_fifo_drv.start,
			// 						tr_fifo_drv.tx_data,
			// 						tr_fifo_drv.rx_data,
			// 						tr_fifo_drv.busy,
			// 						tr_fifo_drv.done,
			// 						tr_fifo_drv.mosi,
			// 						tr_fifo_drv.miso,
			// 						tr_fifo_drv.cs_n,
			// 						tr_fifo_drv.sample_type,
			// 						tr_fifo_drv.tran_is_drv_type,
			// 						tr_fifo_drv.num_rsample
			// 				), 
			// 				UVM_MEDIUM)

			// 				`uvm_info("IN_FIFO", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b, num_rsample: %0d",
			// 						tr_fifo_con.rst_n,
			// 							tr_fifo_con.sclk,
			// 							tr_fifo_con.start,
			// 							tr_fifo_con.tx_data,
			// 							tr_fifo_con.rx_data,
			// 							tr_fifo_con.busy,
			// 							tr_fifo_con.done,
			// 							tr_fifo_con.mosi,
			// 							tr_fifo_con.miso,
			// 							tr_fifo_con.cs_n,
			// 							tr_fifo_con.sample_type,
			// 							tr_fifo_con.tran_is_drv_type,
			// 							tr_fifo_con.num_rsample
			// 					), 
			// 					UVM_MEDIUM)

			// 			end
			// 	end
			// end

