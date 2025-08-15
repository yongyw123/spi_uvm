class spi_mon extends uvm_monitor;
	`uvm_component_utils(spi_mon)

	localparam TOTAL_NUM_SAMPLE = 8;
	virtual spi_if vif;
	uvm_analysis_port #(spi_tran) mon_ap;

	uvm_event ev_fsclk;
	uvm_event ev_rsclk;
	
	bit mon_is_drv;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		mon_ap = new("mon_ap", this);
		ev_fsclk = new();
		ev_rsclk = new();
		
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		if(!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
			`uvm_error("MONITOR", "Virtual interface (mon_cb) not found in config db")
		end

		// Read config from uvm_config_db
        if (!uvm_config_db#(bit)::get(this, "", "mon_is_drv", mon_is_drv)) begin
			`uvm_error("MONITOR", "monitor type is not config db")
        
		end
		else begin
        	`uvm_info("MONITOR", $sformatf("mon_is_drv = %0b", mon_is_drv), UVM_MEDIUM)
		end

	endfunction

	task run_phase(uvm_phase phase);
		spi_tran tr_dut;
		spi_tran tr_dut_free;
		tr_dut = spi_tran::type_id::create("tr_dut");
		tr_dut_free = spi_tran::type_id::create("tr_dut_free");

		fork
			// free running
			forever begin
				// @(posedge vif.clk or negedge vif.rst_n);
				@(posedge vif.clk);
				tr_dut_free.rst_n = vif.rst_n;
				tr_dut_free.start = vif.start;
				tr_dut_free.tx_data = vif.tx_data;
				tr_dut_free.rx_data = vif.rx_data;
				tr_dut_free.busy = vif.busy;
				tr_dut_free.done = vif.done;
				tr_dut_free.sclk = vif.sclk;
				tr_dut_free.mosi = vif.mosi;
				tr_dut_free.miso = vif.miso;
				tr_dut_free.cs_n = vif.cs_n;
				tr_dut_free.sample_type = "free";
				tr_dut_free.tran_is_drv_type = mon_is_drv;
				
				// determine which tx_data is registered;
				if(vif.rst_n == 1'b1) begin
					if((vif.cs_n == 1'b1) && (vif.start == 1'b1)) begin
						tr_dut_free.tx_data_reg = vif.tx_data;
						`uvm_info("MONITOR", $sformatf("[FREE] new tx_data registered;"), UVM_MEDIUM)
					end
				end

				// if reset; clear the qu1eues for other sampling block;
				if(vif.rst_n == 1'b0) begin
					`uvm_info("MONITOR", $sformatf("[FREE] reset is asserted;"), UVM_MEDIUM)
					// tr_dut.sample_type = "free";
					tr_dut.rst_n = vif.rst_n;
					tr_dut.start = vif.start;
					tr_dut.tx_data = vif.tx_data;
					tr_dut.rx_data = vif.rx_data;
					tr_dut.busy = vif.busy;
					tr_dut.done = vif.done;
					tr_dut.sclk = vif.sclk;
					tr_dut.mosi = vif.mosi;
					tr_dut.miso = vif.miso;
					tr_dut.cs_n = vif.cs_n;
					tr_dut.tran_is_drv_type = mon_is_drv;

					tr_dut.mosi_rq_clear();
					tr_dut.mosi_fq_clear();
					tr_dut.miso_rq_clear();
					tr_dut.miso_fq_clear();
					mon_ap.write(tr_dut);
				end
				
				mon_ap.write(tr_dut_free);
			end

			// falling sampling;
			forever begin
				// @(negedge vif.sclk or ~vif.rst_n)
				@(negedge vif.sclk)
				tr_dut.rst_n = vif.rst_n;
				tr_dut.start = vif.start;
				tr_dut.tx_data = vif.tx_data;
				tr_dut.rx_data = vif.rx_data;
				tr_dut.busy = vif.busy;
				tr_dut.done = vif.done;
				tr_dut.sclk = vif.sclk;
				tr_dut.mosi = vif.mosi;
				tr_dut.miso = vif.miso;
				tr_dut.cs_n = vif.cs_n;
				tr_dut.sample_type = "fall";
				tr_dut.tran_is_drv_type = mon_is_drv;

				if(vif.rst_n) begin
					// deserialize miso and mosi;
					tr_dut.mosi_fpush_bit(vif.mosi);
					tr_dut.miso_fpush_bit(vif.miso);

					// increment;
					tr_dut.num_mosi_fsample++;
					tr_dut.num_miso_fsample++;			
				end
				else begin
					`uvm_info("MONITOR - FALLING", $sformatf("reset asserted -> clearing the transaction queue"), UVM_MEDIUM)
					tr_dut.mosi_fq_clear();
					tr_dut.miso_fq_clear();

					tr_dut.num_mosi_fsample = 0;
					tr_dut.num_miso_fsample = 0;
				end

				
				`uvm_info("MONITOR - FALLING", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b, num_mosi_rsample: %0d, num_mosi_fsample: %0d, num_miso_rsample: %0d, num_miso_fsample: %0d, mosi_rdata_q: %8b, mosi_fdata_q: %8b, miso_rdata_q: %8b, miso_fdata_q: %8b",
						tr_dut.rst_n,
						tr_dut.sclk,
						tr_dut.start,
						tr_dut.tx_data,
						tr_dut.rx_data,
						tr_dut.busy,
						tr_dut.done,
						tr_dut.mosi,
						tr_dut.miso,
						tr_dut.cs_n,
						tr_dut.sample_type,
						tr_dut.tran_is_drv_type,
						tr_dut.num_mosi_rsample,
						tr_dut.num_mosi_fsample,
						tr_dut.num_miso_rsample,
						tr_dut.num_miso_fsample,
						tr_dut.mosi_rdata_q[0],
						tr_dut.mosi_fdata_q[0],
						tr_dut.miso_rdata_q[0],
						tr_dut.miso_fdata_q[0]
					), 
					UVM_MEDIUM
				)

				// send the packet;
				mon_ap.write(tr_dut);
				
				// wrap around;
				tr_dut.num_mosi_fsample = tr_dut.num_mosi_fsample % 8;
				tr_dut.num_miso_fsample = tr_dut.num_miso_fsample % 8;
			end
			
			// rising sampling;
			forever begin
				// @(posedge vif.sclk or ~vif.rst_n)
				@(posedge vif.sclk)
				
				// need to delay one sys clk to sample valid data;
				// @(posedge vif.clk);

				tr_dut.rst_n = vif.rst_n;
				tr_dut.start = vif.start;
				tr_dut.tx_data = vif.tx_data;
				tr_dut.rx_data = vif.rx_data;
				tr_dut.busy = vif.busy;
				tr_dut.done = vif.done;
				tr_dut.sclk = vif.sclk;
				tr_dut.mosi = vif.mosi;
				tr_dut.miso = vif.miso;
				tr_dut.cs_n = vif.cs_n;
				tr_dut.sample_type = "rising";
				tr_dut.tran_is_drv_type = mon_is_drv;

				if(vif.rst_n) begin
					// deserialize miso;	
					tr_dut.mosi_rpush_bit(vif.mosi);
					tr_dut.miso_rpush_bit(vif.miso);

					// increment;
					tr_dut.num_mosi_rsample++;
					tr_dut.num_miso_rsample++;
				end
				else begin
					`uvm_info("MONITOR - FALLING", $sformatf("reset asserted -> clearing the transaction queue"), UVM_MEDIUM)
					tr_dut.mosi_rq_clear();
					tr_dut.miso_rq_clear();
					tr_dut.num_mosi_rsample = 0;
					tr_dut.num_miso_rsample = 0;
				end

				`uvm_info("MONITOR - RISING", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b, num_mosi_rsample: %0d, num_mosi_fsample: %0d, num_miso_rsample: %0d, num_miso_fsample: %0d, mosi_rdata_q: %8b, mosi_fdata_q: %8b, miso_rdata_q: %8b, miso_fdata_q: %8b",
						tr_dut.rst_n,
						tr_dut.sclk,
						tr_dut.start,
						tr_dut.tx_data,
						tr_dut.rx_data,
						tr_dut.busy,
						tr_dut.done,
						tr_dut.mosi,
						tr_dut.miso,
						tr_dut.cs_n,
						tr_dut.sample_type,
						tr_dut.tran_is_drv_type,
						tr_dut.num_mosi_rsample,
						tr_dut.num_mosi_fsample,
						tr_dut.num_miso_rsample,
						tr_dut.num_miso_fsample,
						tr_dut.mosi_rdata_q[0],
						tr_dut.mosi_fdata_q[0],
						tr_dut.miso_rdata_q[0],
						tr_dut.miso_fdata_q[0]
					), 
					UVM_MEDIUM
				)
				
				// send the packet;
				mon_ap.write(tr_dut);
				
				// wrap around;
				tr_dut.num_miso_rsample = tr_dut.num_miso_rsample % 8;
				tr_dut.num_mosi_rsample = tr_dut.num_mosi_rsample % 8;
			end
		join
	endtask

endclass
