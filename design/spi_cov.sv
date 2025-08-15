class spi_cov extends uvm_component;
  `uvm_component_utils(spi_cov)

  uvm_analysis_imp #(spi_tran, spi_cov) cov_imp;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    cov_imp = new("cov_imp", this);
    spi_cg = new();
    spi_cg.set_inst_name($sformatf("%s\ (spi_cg\)", get_full_name()));
  endfunction

  function void write(spi_tran tr);
    spi_cg.sample(tr);
  endfunction

  covergroup spi_cg with function sample(spi_tran tr);
    option.per_instance = 1;
    option.weight = 1;
    option.comment = "spi_cg coverage";

    cp_rst_n: coverpoint tr.rst_n {
      option.comment = "cp_rst_n coverage";
      option.weight  = 1;
      bins low  = {0};
      bins high = {1};
    }

    cp_start: coverpoint tr.start {
      option.comment = "cp_start coverage";
      option.weight  = 1;
      bins low  = {0};
      bins high = {1};
    }

	cp_cs_n: coverpoint tr.cs_n {
      option.comment = "cp_cs_n coverage";
      option.weight  = 1;
      bins low  = {0};
      bins high = {1};
    }

    cp_tx_data: coverpoint tr.tx_data {
      option.comment = "cp_tx_data coverage";
      option.weight  = 1;
      bins zero     = {0};
      bins non_zero = {[8'h01:8'hFF]};
    }

    cp_rx_data: coverpoint tr.rx_data {
      option.comment = "cp_rx_data coverage";
      option.weight  = 1;
      bins zero     = {0};
      bins non_zero = {[8'h01:8'hFF]};
    }

    cp_busy: coverpoint tr.busy {
      option.comment = "cp_busy coverage";
      option.weight  = 1;
      bins low  = {0};
      bins high = {1};
    }

    cp_done: coverpoint tr.done {
      option.comment = "cp_done coverage";
      option.weight  = 1;
      bins low  = {0};
      bins high = {1};
    }

    cp_sclk: coverpoint tr.sclk {
      option.comment = "cp_sclk coverage";
      option.weight  = 1;
      bins low  = {0};
      bins high = {1};
    }

    cp_mosi: coverpoint tr.mosi {
      option.comment = "cp_mosi coverage";
      option.weight  = 1;
      bins low  = {0};
      bins high = {1};
    }

    cp_miso: coverpoint tr.miso {
      option.comment = "cp_miso coverage";
      option.weight  = 1;
      bins low  = {0};
      bins high = {1};
    }

  endgroup

  function void report_phase(uvm_phase phase);
    `uvm_info("coverage", $sformatf("Coverage spi		: %.2f%%", spi_cg.get_coverage()), UVM_NONE)
    `uvm_info("coverage", $sformatf("Coverage rst_n		: %.2f%%", spi_cg.cp_rst_n.get_coverage()), UVM_NONE)
    `uvm_info("coverage", $sformatf("Coverage start		: %.2f%%", spi_cg.cp_start.get_coverage()), UVM_NONE)
    `uvm_info("coverage", $sformatf("Coverage tx_data	: %.2f%%", spi_cg.cp_tx_data.get_coverage()), UVM_NONE)
    `uvm_info("coverage", $sformatf("Coverage rx_data	: %.2f%%", spi_cg.cp_rx_data.get_coverage()), UVM_NONE)
    `uvm_info("coverage", $sformatf("Coverage busy		: %.2f%%", spi_cg.cp_busy.get_coverage()), UVM_NONE)
    `uvm_info("coverage", $sformatf("Coverage done		: %.2f%%", spi_cg.cp_done.get_coverage()), UVM_NONE)
    `uvm_info("coverage", $sformatf("Coverage sclk		: %.2f%%", spi_cg.cp_sclk.get_coverage()), UVM_NONE)
    `uvm_info("coverage", $sformatf("Coverage mosi		: %.2f%%", spi_cg.cp_mosi.get_coverage()), UVM_NONE)
    `uvm_info("coverage", $sformatf("Coverage miso		: %.2f%%", spi_cg.cp_miso.get_coverage()), UVM_NONE)
    `uvm_info("coverage", $sformatf("Coverage cs_n		: %.2f%%", spi_cg.cp_cs_n.get_coverage()), UVM_NONE)
  endfunction//report_phase

endclass//spi_cov