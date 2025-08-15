class spi_test extends uvm_test;
	`uvm_component_utils(spi_test)

	spi_env env;
	
	spi_seq_init seq_init;
	spi_seq_hs seq_hs;
	spi_seq_rst seq_rst;
	spi_seq_strt seq_strt;
	spi_seq_tx seq_tx;
	spi_seq_rnd seq_rnd;

	int tb_num_seq = 100;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction//new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = spi_env::type_id::create("env", this);
	endfunction//build_phase

	task run_phase(uvm_phase phase);
	
		seq_init = spi_seq_init::type_id::create("seq_init");
		seq_hs = spi_seq_hs::type_id::create("seq_hs");
		seq_rst = spi_seq_rst::type_id::create("seq_rst");
		seq_strt = spi_seq_strt::type_id::create("seq_strt");
		seq_tx = spi_seq_tx::type_id::create("seq_tx");
		seq_rnd = spi_seq_rnd::type_id::create("seq_rnd");

		seq_init.tb_num_seq = tb_num_seq;
		seq_hs.tb_num_seq = tb_num_seq;
		seq_rst.tb_num_seq = tb_num_seq;
		seq_strt.tb_num_seq = tb_num_seq;
		seq_tx.tb_num_seq = tb_num_seq;
		seq_rnd.tb_num_seq = tb_num_seq;
		
		`uvm_info("TEST", $sformatf("Starting sequences with TB_NUM_SEQ: %0d", tb_num_seq), UVM_MEDIUM)


		phase.raise_objection(this);


		////////////////////////////
		// FUTURE/TODO:
		////////////////////////////
		// allow user to select which sequence
		// to execute;
		// so that we could test the dut
		// per sequence basis.
		// but for now issue the sequence sequentially;
		seq_init.start(env.agt_drv.sqr);
		seq_hs.start(env.agt_drv.sqr);
		seq_tx.start(env.agt_drv.sqr);
		seq_rst.start(env.agt_drv.sqr);
		seq_strt.start(env.agt_drv.sqr);
		seq_rnd.start(env.agt_drv.sqr);

		///////////////////////
		// FUTURE/TODO
		///////////////////////

		// then spam in parallel; allow random arbitration;
		// fork
		// 	seq_tx.start(env.agt_drv.sqr);
		// 	seq_strt.start(env.agt_drv.sqr);
		// 	seq_rnd.start(env.agt_drv.sqr);
		// join
		
		phase.drop_objection(this);

	endtask//run_phase

endclass//spi_test
