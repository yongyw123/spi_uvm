class spi_env extends uvm_env;
  `uvm_component_utils(spi_env)

  spi_agt agt_drv;
  spi_agt agt_con;
  spi_scb scb;
  // spi_cov cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Set driver agent as active
    uvm_config_db#(uvm_active_passive_enum)::set(this, "agt_drv", "is_active", UVM_ACTIVE);
    
    // set consumer agent as inactive;
    uvm_config_db#(uvm_active_passive_enum)::set(this, "agt_con", "is_active", UVM_PASSIVE);

    agt_drv = spi_agt::type_id::create("agt_drv", this);
    agt_con = spi_agt::type_id::create("agt_con", this);

    scb = spi_scb::type_id::create("scb", this);
    // cov = spi_cov::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt_drv.agt_ap.connect(scb.scb_imp);
    agt_con.agt_ap.connect(scb.scb_imp);
    // agt.agt_ap.connect(cov.cov_imp);
  endfunction
endclass
