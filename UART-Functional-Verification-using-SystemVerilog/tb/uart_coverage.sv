// ============================================================
// Class     : uart_coverage
// Project   : UART Functional Verification using SystemVerilog
// Description: Functional coverage collection using covergroups
//              Tracks: data values, baud rates, parity modes,
//              error scenarios, back-to-back transfers
// ============================================================

class uart_coverage;

    // ---- Sampled fields ----
    bit [7:0] cov_data;
    bit       cov_parity_en;
    bit       cov_parity_type;
    int       cov_baud_rate;
    bit       cov_parity_err;
    bit       cov_frame_err;

    // ---- Covergroup: Data pattern coverage ----
    covergroup cg_data_values;
        cp_data: coverpoint cov_data {
            bins zero        = {8'h00};
            bins ones        = {8'hFF};
            bins lower_byte  = {[8'h01 : 8'h7F]};
            bins upper_byte  = {[8'h80 : 8'hFE]};
        }
        cp_parity_en: coverpoint cov_parity_en {
            bins parity_off = {1'b0};
            bins parity_on  = {1'b1};
        }
        cp_parity_type: coverpoint cov_parity_type {
            bins even = {1'b0};
            bins odd  = {1'b1};
        }
        // Cross: data range × parity mode
        cx_data_parity: cross cp_data, cp_parity_en;
    endgroup

    // ---- Covergroup: Baud rate coverage ----
    covergroup cg_baud_rates;
        cp_baud: coverpoint cov_baud_rate {
            bins baud_9600   = {9600};
            bins baud_19200  = {19200};
            bins baud_38400  = {38400};
            bins baud_57600  = {57600};
            bins baud_115200 = {115200};
            bins baud_230400 = {230400};
        }
    endgroup

    // ---- Covergroup: Error scenario coverage ----
    covergroup cg_errors;
        cp_parity_err: coverpoint cov_parity_err {
            bins no_err  = {1'b0};
            bins err_seen = {1'b1};
        }
        cp_frame_err: coverpoint cov_frame_err {
            bins no_err  = {1'b0};
            bins err_seen = {1'b1};
        }
    endgroup

    // ---- Constructor ----
    function new();
        cg_data_values = new();
        cg_baud_rates  = new();
        cg_errors      = new();
    endfunction

    // ---- Sample a transaction ----
    function void sample(uart_transaction txn);
        cov_data        = txn.data;
        cov_parity_en   = txn.parity_en;
        cov_parity_type = txn.parity_type;
        cov_baud_rate   = txn.baud_rate;
        cov_parity_err  = txn.parity_err_seen;
        cov_frame_err   = txn.frame_err_seen;

        cg_data_values.sample();
        cg_baud_rates.sample();
        cg_errors.sample();
    endfunction

    // ---- Coverage report ----
    function void report();
        $display("\n");
        $display("============================================================");
        $display("  FUNCTIONAL COVERAGE REPORT");
        $display("============================================================");
        $display("  Data Values Coverage   : %0.2f%%", cg_data_values.get_coverage());
        $display("  Baud Rate Coverage     : %0.2f%%", cg_baud_rates.get_coverage());
        $display("  Error Scenario Coverage: %0.2f%%", cg_errors.get_coverage());
        $display("  Overall Coverage       : %0.2f%%",
                 (cg_data_values.get_coverage() +
                  cg_baud_rates.get_coverage()  +
                  cg_errors.get_coverage()) / 3.0);
        $display("============================================================\n");
    endfunction

endclass : uart_coverage
