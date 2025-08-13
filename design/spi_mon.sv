class spi_mon extends uvm_monitor;
	`uvm_component_utils(spi_mon)

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
		
		fork
			// falling sampling;
			forever begin
				// @(posedge vif.clk iff vif.start);
				ev_fsclk.wait_on();
				@(posedge vif.clk);
				tr_dut = spi_tran::type_id::create("tr_dut");
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

				`uvm_info("MONITOR", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b",
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
						tr_dut.tran_is_drv_type
					), 
					UVM_MEDIUM)

				mon_ap.write(tr_dut);
				ev_fsclk.reset();
			end

			// rising sampling;
			forever begin
				ev_rsclk.wait_on();
				@(posedge vif.clk);
				tr_dut = spi_tran::type_id::create("tr_dut");
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

				`uvm_info("MONITOR", $sformatf("sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b",
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
						tr_dut.tran_is_drv_type
					), 
					UVM_MEDIUM)

				mon_ap.write(tr_dut);
				ev_rsclk.reset();
			end

			forever begin
				@(negedge vif.sclk) ev_fsclk.trigger();
				`uvm_info("MONITOR", $sformatf("EVENT: falling sclk detected"), UVM_MEDIUM)
			end

			forever begin
				@(posedge vif.sclk) ev_rsclk.trigger();
				`uvm_info("MONITOR", $sformatf("EVENT: rising sclk detected"), UVM_MEDIUM)
			end
		join

	endtask
endclass
