interface spi_if;
	logic clk;
	logic rst_n;
	logic start;
	logic [7:0] tx_data;
	logic [7:0] rx_data;
	logic busy;
	logic done;
	
	logic sclk;
	logic mosi;
	logic miso;
	logic cs_n;

	modport tb(
		input clk,
		output rst_n,
		output start,
		output tx_data,
		input rx_data,
		input busy,
		input done,

		input sclk,
		input mosi,
		output miso,
		input cs_n
	);

	modport dut(
		input clk,
		input rst_n,
		input start,
		input tx_data,
		output rx_data,
		output busy,
		output done,

		output sclk,
		output mosi,
		input miso,
		output cs_n
	);

	// clocking dut_cb @(posedge clk);
	// 	default input #1step output #1;
		
	// 	output rx_data, busy, done;
	// 	input rst_n, start, tx_data;
	// endclocking

	// modport dut(
	// 	clocking dut_cb,
	// 	output sclk,
	// 	output mosi,
	// 	input miso,
	// 	output cs_n
	// );

	

endinterface//spi_if
