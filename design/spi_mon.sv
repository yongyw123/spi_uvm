class spi_mon extends uvm_monitor;
	`uvm_component_utils(spi_mon)

	virtual spi_if vif;
	uvm_analysis_port #(spi_tran) mon_ap;

	uvm_event ev_fsclk;
	uvm_event ev_rsclk;

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

		`uvm_info("MONITOR", $sformatf("Monitor has been built."), UVM_MEDIUM)
	endfunction

	task run_phase(uvm_phase phase);
		spi_tran tr_dut;
		`uvm_info("MONITOR", $sformatf("Entering monitor run phase"), UVM_MEDIUM)
		
		fork
			forever begin
				// @(posedge vif.clk iff vif.start);
				ev_fsclk.wait_on();
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

				`uvm_info("MONITOR", $sformatf("start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b",
						tr_dut.start,
						tr_dut.tx_data,
						tr_dut.rx_data,
						tr_dut.busy,
						tr_dut.done,
						tr_dut.mosi,
						tr_dut.miso,
						tr_dut.cs_n
					), 
					UVM_MEDIUM)

				mon_ap.write(tr_dut);
				ev_fsclk.reset();
			end

			forever begin
				@(negedge vif.sclk) ev_fsclk.trigger();
				`uvm_info("MONITOR", $sformatf("EVENT: falling sclk detected"), UVM_MEDIUM)
			end

			forever begin
				@(negedge vif.sclk) ev_rsclk.trigger();
				`uvm_info("MONITOR", $sformatf("EVENT: rising sclk detected"), UVM_MEDIUM)
				ev_rsclk.reset();
			end
		join

	endtask
endclass
