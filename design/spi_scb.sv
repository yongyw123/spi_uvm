class spi_scb extends uvm_scoreboard;
	`uvm_component_utils(spi_scb)

	uvm_analysis_imp #(spi_tran, spi_scb) scb_imp;
	uvm_tlm_analysis_fifo #(spi_tran) drv_fifo;
	uvm_tlm_analysis_fifo #(spi_tran) con_fifo;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		scb_imp = new("scb_imp", this);

	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		drv_fifo = new("drv_fifo", this);
		con_fifo = new("con_fifo", this);

	endfunction

	function void write(spi_tran tr_dut);
		`uvm_info("SCB", $sformatf("Writing SCB."), UVM_MEDIUM)
		if(tr_dut.tran_is_drv_type) begin
			drv_fifo.try_put(tr_dut);
		end
		else begin
			con_fifo.try_put(tr_dut);
		end
		
	endfunction

	task run_phase(uvm_phase phase);
		`uvm_info("SCB", $sformatf("Entering SCB."), UVM_MEDIUM)
		fork
			forever begin
				spi_tran tr_dut;
				`uvm_info("SCB", $sformatf("Waiting OUT_FIFO."), UVM_MEDIUM)
				drv_fifo.get(tr_dut);
				// `uvm_info("SCB_FIFO",$sformatf("m_trn: %08b",tr_dut.tx_data), UVM_MEDIUM)
				`uvm_info("OUT_FIFO", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b",
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
			end

			forever begin
				spi_tran tr_dut;
				`uvm_info("SCB", $sformatf("Waiting IN_FIFO."), UVM_MEDIUM)
				con_fifo.get(tr_dut);
				// `uvm_info("SCB_FIFO",$sformatf("m_trn: %08b",tr_dut.tx_data), UVM_MEDIUM)
				`uvm_info("IN_FIFO", $sformatf("rst_n: %0b, sclk: %0b, start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b, sampling_type: %s, tran_is_drv: %0b",
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
			end
		join

	endtask

endclass
