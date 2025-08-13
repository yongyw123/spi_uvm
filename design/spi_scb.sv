class spi_scb extends uvm_scoreboard;
	`uvm_component_utils(spi_scb)

	uvm_analysis_imp #(spi_tran, spi_scb) scb_imp;
	uvm_tlm_analysis_fifo #(spi_tran) drv_fifo;
	uvm_tlm_analysis_fifo #(spi_tran) con_fifo;
	
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

	endfunction

	function void write(spi_tran tr_dut);
		// driver;
		if(tr_dut.tran_is_drv_type) begin
			drv_fifo.try_put(tr_dut);
		end
		// consumer;
		else begin
			con_fifo.try_put(tr_dut);
		end
		
	endfunction

	task run_phase(uvm_phase phase);
		spi_tran tr_fifo_drv;
		spi_tran tr_fifo_con;
		
		forever begin
			fork
				begin drv_fifo.get(tr_fifo_drv); end
				begin con_fifo.get(tr_fifo_con); end
			join

			/////////////////////
			// TEST 01: RESET;
			/////////////////////
			if(tr_fifo_drv.rst_n == 1'b0) begin
				sva_t1: assert(
					(tr_fifo_drv.busy == 1'b0) &&
					(tr_fifo_drv.done == 1'b0) &&
					(tr_fifo_drv.sclk == 1'b0) &&
					(tr_fifo_drv.mosi == 1'b0) &&
					(tr_fifo_drv.cs_n == 1'b1) &&
					(tr_fifo_drv.rx_data == '0)
				) begin
					passed_count++; 
					`uvm_info("SCOREBOARD", $sformatf("TEST RESET - PASSED"), UVM_MEDIUM)
				end
					else begin
						failed_count++;
						`uvm_info("SCOREBOARD", $sformatf("TEST RESET - FAILED"), UVM_MEDIUM)
					end
			end

			/////////////////////
			// TEST 02: IDLE
			/////////////////////
			// not reset not start;
			if((tr_fifo_drv.rst_n == 1'b1) && (tr_fifo_drv.start == 1'b0))begin
				sva_t2: assert(
					(tr_fifo_drv.busy == 1'b0) &&
					(tr_fifo_drv.done == 1'b0) &&
					(tr_fifo_drv.sclk == 1'b0) &&
					(tr_fifo_drv.mosi == 1'b0) &&
					(tr_fifo_drv.cs_n == 1'b1) &&
					(tr_fifo_drv.rx_data == '0)
				) begin
					passed_count++;
					`uvm_info("SCOREBOARD", $sformatf("TEST IDLE - PASSED"), UVM_MEDIUM)
				end
				else begin
					failed_count++;
					`uvm_info("SCOREBOARD", $sformatf("TEST IDLE - FAILED"), UVM_MEDIUM)
				end
			end
		end

		// /////////////////////
		// // TEST 03: TX -> MOSI
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

