class spi_test extends uvm_test;
	`uvm_component_utils(spi_test)

	spi_env env;
	
	spi_seq_init seq_init;
	spi_seq_rst seq_rst;
	spi_seq_strt seq_strt;
	spi_seq_tx seq_tx;
	spi_seq_rnd seq_rnd;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = spi_env::type_id::create("env", this);
	endfunction

	task run_phase(uvm_phase phase);
	
		seq_init = spi_seq_init::type_id::create("seq_init");
		seq_rst = spi_seq_rst::type_id::create("seq_rst");
		seq_strt = spi_seq_strt::type_id::create("seq_strt");
		seq_tx = spi_seq_tx::type_id::create("seq_tx");
		seq_rnd = spi_seq_rnd::type_id::create("seq_rnd");
		
		`uvm_info("TEST", $sformatf("Starting sequences"), UVM_MEDIUM)

		phase.raise_objection(this);

		// issue the sequence sequentially;
		// then spam in parallel; allow random arbitration;

		seq_init.start(env.agt_drv.sqr);
		seq_tx.start(env.agt_drv.sqr);
		// seq_rst.start(env.agt_drv.sqr);
		// seq_strt.start(env.agt_drv.sqr);
		// seq_rnd.start(env.agt_drv.sqr);

		// fork
		// 	seq_tx.start(env.agt_drv.sqr);
		// 	seq_strt.start(env.agt_drv.sqr);
		// 	seq_rnd.start(env.agt_drv.sqr);
		// join
		
	phase.drop_objection(this);

	endtask
endclass
