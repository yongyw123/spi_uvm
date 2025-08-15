`include "spi_if.sv"
`include "spi.sv"

module spi_tb;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	// $time is a built-in system function
	initial $display(">>>>>>>> SIM TIME START: %0t", $time);
	final   $display(">>>>>>>> SIM TIME END  : %0t", $time);

	// Include all required files
	`include "spi_tran.sv"

	`include "spi_seq_init.sv"
	`include "spi_seq_strt.sv"
	`include "spi_seq_rst.sv"
	`include "spi_seq_tx.sv"
	`include "spi_seq_rnd.sv"
	`include "spi_seq_hs.sv"

	`include "spi_sqr.sv"
	`include "spi_drv.sv"
	`include "spi_mon.sv"
	`include "spi_agt.sv"
	`include "spi_scb.sv"
	`include "spi_cov.sv"
	`include "spi_env.sv"
	`include "spi_test.sv"

	spi_if spi_if0();

	spi #(
		.CLK_DIV(4)
	)dut(
		.clk(spi_if0.clk),
		.rst_n(spi_if0.rst_n),
		.start(spi_if0.start),
		.tx_data(spi_if0.tx_data),
		.rx_data(spi_if0.rx_data),
		.busy(spi_if0.busy),
		.done(spi_if0.done),
		.sclk(spi_if0.sclk),
		.mosi(spi_if0.mosi),
		.miso(spi_if0.miso),
		.cs_n(spi_if0.cs_n)
	);

	///////////////////////
	// dummy slave;
	///////////////////////
	bit [7:0] SLAVE_RESET_RESPONSE = 8'hB9;
	int slave_reset_response = SLAVE_RESET_RESPONSE;

	// Simple SPI slave model for testing
	logic [7:0] slave_rx_data;
	logic [7:0] slave_tx_data = SLAVE_RESET_RESPONSE;

	always @(posedge spi_if0.sclk or negedge spi_if0.rst_n or posedge spi_if0.cs_n) begin
		if (!spi_if0.rst_n) begin
			slave_rx_data <= 8'h00;
			spi_if0.miso <= 1'b0;
			slave_tx_data <= SLAVE_RESET_RESPONSE;
		end
		else if (spi_if0.cs_n) begin
			spi_if0.miso <= 1'b0;
			slave_tx_data <= SLAVE_RESET_RESPONSE;

			`uvm_info("SLV-RLD", $sformatf("RX_REG=0x%2h \(%8b\), TX_REG=0x%2h \(%8b\)",
												slave_rx_data, slave_rx_data, slave_tx_data, slave_tx_data), UVM_MEDIUM)
		end
		else begin
			// Shift in MOSI on rising edge
			slave_rx_data <= {slave_rx_data[6:0], spi_if0.mosi};

			// Update MISO immediately for next bit
			spi_if0.miso <= slave_tx_data[7];
			slave_tx_data <= {slave_tx_data[6:0], 1'b0};

			`uvm_info("SLV", $sformatf("RX_REG=0x%2h \(%8b\), TX_REG=0x%2h \(%8b\)",
										slave_rx_data, slave_rx_data, slave_tx_data, slave_tx_data), UVM_MEDIUM)
		end
	end

	initial begin
		spi_if0.clk = 0;
		forever #5 spi_if0.clk = ~spi_if0.clk;
	end

	initial begin
		uvm_config_db#(virtual spi_if)::set(null, "*", "vif", spi_if0);
		uvm_config_db#(int)::set(null, "*", "slave_reset_response", slave_reset_response);
		run_test("spi_test");
	end

	initial begin
		$fsdbDumpfile("waveform.fsdb");
		$fsdbDumpSVA(0, spi_tb);
		$fsdbDumpvars(0, spi_tb);
	end
endmodule
