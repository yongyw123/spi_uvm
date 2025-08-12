class spi_scb extends uvm_scoreboard;
	`uvm_component_utils(spi_scb)

	uvm_analysis_imp #(spi_tran, spi_scb) scb_imp;
	uvm_tlm_analysis_fifo #(spi_tran) m_trn_fifo;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		scb_imp = new("scb_imp", this);

	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_trn_fifo = new("m_trn_fifo", this);
	endfunction

	function void write(spi_tran tr_dut);
		`uvm_info("SCB", $sformatf("Writing SCB."), UVM_MEDIUM)
		m_trn_fifo.try_put(tr_dut);
		
	endfunction

	task run_phase(uvm_phase phase);
		`uvm_info("SCB", $sformatf("Entering SCB."), UVM_MEDIUM)
		forever begin
			spi_tran tr_dut;
			`uvm_info("SCB", $sformatf("Waiting SCB FIFO."), UVM_MEDIUM)
			m_trn_fifo.get(tr_dut);
			// // `uvm_info("SCB_FIFO",$sformatf("m_trn: %08b",tr_dut.tx_data), UVM_MEDIUM)
			// `uvm_info("SCB_FIFO", $sformatf("start: %0b, tx_data: %2b, rx_data: %2b, busy: %0b, done: %0d, mosi: %0b, miso: %0b, cs_n: %0b",
			// 		tr_dut.start,
			// 		tr_dut.tx_data,
			// 		tr_dut.rx_data,
			// 		tr_dut.busy,
			// 		tr_dut.done,
			// 		tr_dut.mosi,
			// 		tr_dut.miso,
			// 		tr_dut.cs_n
			// 	), 
			// 	UVM_MEDIUM)
		end
	endtask

endclass
