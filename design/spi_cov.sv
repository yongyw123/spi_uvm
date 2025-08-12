class spi_cov extends uvm_component;
  `uvm_component_utils(spi_cov)
    
  // Use implementation port to receive transactions
  uvm_analysis_imp #(spi_tran, spi_cov) cov_imp;

  // function new(string name, uvm_component parent);
  //   super.new(name, parent);
  //   cov_imp = new("cov_imp", this);
  //   spi_cg = new();
  //   spi_cg.set_inst_name($sformatf("%s\ (spi_cg\)", get_full_name()));
  // endfunction

  // // This will be called when transactions arrive
  // function void write(spi_tran tr);
  //   spi_cg.sample(tr);
  // endfunction

  // covergroup spi_cg with function sample(spi_tran tr);
  //   option.per_instance = 1;
  //   option.weight = 1;
  //   option.comment = "THIS IS MY BUS_CG COVERAGE";
        
  //   addr_cp: coverpoint tr.addr {
  //     option.comment = "THIS IS MY BUS_CG:ADDR_CP COVERAGE";
  //     option.weight = 2;
  //     bins low_addr = {[0:127]};
  //     bins high_addr = {[128:255]};
  //   }
  //   data_cp: coverpoint tr.data {
  //     option.comment = "THIS IS MY BUS_CG:DATA_CP COVERAGE";
  //     option.weight = 3;
  //     bins zero_data = {0};
  //     bins small_data = {[1:1000]};
  //     bins large_data = {[1001:32'hFFFF_FFFF]};
  //   }
  //   write_cp: coverpoint tr.write {
  //     option.comment = "THIS IS MY BUS_CG:WRITE_CP COVERAGE";
  //   }
  //   addr_x_write: cross addr_cp, write_cp {
  //     option.comment = "THIS IS MY BUS_CG:ADDR_X_WRITE_CP COVERAGE";
  //   }
  // endgroup

  // function void report_phase(uvm_phase phase);
  //   `uvm_info("COVERAGE", $sformatf("Coverage spi_cg      : %.2f%%", spi_cg.get_coverage()), UVM_NONE)
  //   `uvm_info("COVERAGE", $sformatf("Coverage addr_cp     : %.2f%%", spi_cg.addr_cp.get_coverage()), UVM_NONE)
  //   `uvm_info("COVERAGE", $sformatf("Coverage data_cp     : %.2f%%", spi_cg.data_cp.get_coverage()), UVM_NONE)
  //   `uvm_info("COVERAGE", $sformatf("Coverage write_cp    : %.2f%%", spi_cg.write_cp.get_coverage()), UVM_NONE)
  //   `uvm_info("COVERAGE", $sformatf("Coverage addr_x_write: %.2f%%", spi_cg.addr_x_write.get_coverage()), UVM_NONE)
  // endfunction
endclass
