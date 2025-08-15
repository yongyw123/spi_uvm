module spi_sva #(
    parameter int CLK_DIV = 4
)(
    input logic        clk,      // System clock
    input logic        rst_n,    // Active-low reset
    input logic        start,    // Start transmission
    input logic [7:0]  tx_data,  // Data to transmit
    input logic [7:0]  rx_data,  // Received data
    input logic        busy,     // Transmission in progress
    input logic        done,     // Transmission complete
    
    input logic        sclk,     // SPI clock
    input logic        mosi,     // Master out, slave in
    input logic        miso,     // Master in, slave out
    input logic        cs_n      // Chip select (active low)

);
    localparam SCLK_PERIOD = 2*CLK_DIV;

    // reset assertion must be combi;
    // reason: async;
    always_comb begin: cb_sva_rst
        if(~rst_n) begin
            sva_rst: assert final (
                    busy    == 0 &&
                    sclk    == 0 &&
                    cs_n    == 1 &&
                    done    == 0 &&
                    rx_data == 0
                );
        end
    end//sva_rst

    // done must be a pulse;
    property sva_done_pulse;
        @(posedge clk) disable iff(~rst_n)
            $rose(done) |=> $fell(done);
    endproperty

    // once started, busy must assert;
    property sva_start2busy;
        @(posedge clk) disable iff(~rst_n)
            ($rose(start) && (busy == 1'b0)) |=> $rose(busy);
    endproperty

    // once asserted, busy must remain stable for 8 sclk;
    property sva_busy_stable;
        @(posedge clk) disable iff(~rst_n)
            $rose(busy)|=> $stable(busy)[*(SCLK_PERIOD*8)];
    endproperty

    // once started, cs_n must assert;
    property sva_start2cs;
        @(posedge clk) disable iff(~rst_n)
            ($rose(start) && (cs_n == 1'b1)) |=> $fell(cs_n);
    endproperty

    // once asserted, cs_n must remain stable for 8 sclk;
    property sva_cs_stable;
        @(posedge clk) disable iff(~rst_n)
            $fell(cs_n)|=> $stable(cs_n)[*((SCLK_PERIOD)*4)];
    endproperty

    // idle;
    property sva_idle;
        @(posedge clk) disable iff (~rst_n)
            (cs_n) |-> (sclk == 1'b0);
    endproperty
    
    // rx_data must not change until done;
    property sva_rx_data_stable;
        @(posedge clk) disable iff(~rst_n)
            $rose(busy)|=> $stable(rx_data) until(done);
    endproperty

    // rx_data must be updated at the negedge of sclk;
    // per mode: {cphol: 0, cpha: 1};
    property sva_rx_data_neg;
        @(posedge clk) disable iff(~rst_n)
            $changed(rx_data) |-> (
                (sclk == 1'b0) &&
                ($past(sclk, 2) == 1'b1) 
            );
    endproperty

    ap_sva_done_pulse: assert property(sva_done_pulse) else $error("%0t [SVA] expected done signal to be one-clock cycle.", $time);
    ap_sva_start2busy: assert property(sva_start2busy) else $error("%0t [SVA] start -> busy", $time);
    ap_sva_start2cs: assert property(sva_start2cs) else $error("%0t [SVA] start -> cs", $time);
    ap_sva_busy_stable: assert property(sva_busy_stable) else $error("%0t [SVA] busy must be stable for 8 sclk", $time);
    ap_sva_cs_stable: assert property(sva_cs_stable) else $error("%0t [SVA] cs_n must be stable for 8 sclk", $time);
    ap_sva_idle: assert property(sva_idle) else $error("%0t [SVA] expect no sclk during idle", $time);
    ap_sva_rx_data_stable: assert property(sva_rx_data_stable) else $error("%0t [SVA] rx_data must not change until done", $time);
    ap_sva_rx_data_neg: assert property(sva_rx_data_neg) else $error("%0t [SVA] rx_data must only change at the negedge of sclk", $time);
    

endmodule: spi_sva