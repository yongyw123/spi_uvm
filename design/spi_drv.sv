class spi_drv extends uvm_driver #(spi_tran);
	`uvm_component_utils(spi_drv)

	virtual spi_if vif;
	uvm_analysis_port #(spi_tran) drv_ap;

	function new(string name, uvm_component parent);
		super.new(name, parent);
		drv_ap = new("drv_ap", this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual spi_if)::get(this, "", "vif", vif)) begin
			`uvm_error("DRIVER", "Virtual interface (drv_cb) not found in config db")
		end
	endfunction

	task run_phase(uvm_phase phase);
		spi_tran tr;

		// initial reset;
		vif.rst_n <= 1'b0;
		vif.tx_data <= '0;
		vif.start <= 1'b0;

		forever begin
			seq_item_port.get_next_item(tr);

			`uvm_info("DRIVER", $sformatf("Drive tran to DUT: tx_data=0x%8h",
											tr.tx_data), UVM_MEDIUM)
			repeat(10) @(vif.clk);
			vif.rst_n <= 1'b1;

			repeat(10) @(vif.clk);
			vif.tx_data <= tr.tx_data;
			vif.start <= 1'b1;
			wait(vif.busy) @(posedge vif.clk);



			// wait for spi tran to complete;
			wait(vif.done) @(posedge vif.clk);

			`uvm_info("DRIVER", $sformatf("SPI done: %0b", vif.done), UVM_MEDIUM)

			seq_item_port.item_done();
		end
	endtask
endclass
