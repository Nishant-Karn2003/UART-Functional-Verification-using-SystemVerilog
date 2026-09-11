// ============================================================
// Module    : uart_assertions
// Project   : UART Functional Verification using SystemVerilog
// Description: SystemVerilog Assertions (SVA) for UART protocol
//              Bound to DUT ports via interface signals
// ============================================================

module uart_assertions (
    input logic       clk,
    input logic       rst_n,
    input logic       tx,
    input logic       rx,
    input logic       tx_start,
    input logic       tx_busy,
    input logic [7:0] rx_data,
    input logic       rx_valid,
    input logic       parity_err,
    input logic       frame_err
);

    // ---- 1. TX line is HIGH during idle ----
    property p_tx_idle_high;
        @(posedge clk) disable iff (!rst_n)
        (!tx_busy && !tx_start) |-> tx;
    endproperty
    a_tx_idle_high: assert property (p_tx_idle_high)
        else $error("[SVA FAIL] TX not held HIGH during idle at time %0t", $time);

    // ---- 2. Start bit must be LOW ----
    property p_start_bit_low;
        @(posedge clk) disable iff (!rst_n)
        $rose(tx_busy) |-> ##1 !tx;
    endproperty
    a_start_bit_low: assert property (p_start_bit_low)
        else $error("[SVA FAIL] Start bit not LOW at time %0t", $time);

    // ---- 3. No tx_start while busy ----
    property p_no_start_while_busy;
        @(posedge clk) disable iff (!rst_n)
        tx_busy |-> !tx_start;
    endproperty
    a_no_start_while_busy: assert property (p_no_start_while_busy)
        else $error("[SVA FAIL] tx_start asserted while tx_busy at time %0t", $time);

    // ---- 4. rx_valid must be a single-cycle pulse ----
    property p_rx_valid_pulse;
        @(posedge clk) disable iff (!rst_n)
        rx_valid |=> !rx_valid;
    endproperty
    a_rx_valid_pulse: assert property (p_rx_valid_pulse)
        else $error("[SVA FAIL] rx_valid held for more than one cycle at time %0t", $time);

    // ---- 5. Reset deasserts TX cleanly ----
    property p_reset_tx_high;
        @(posedge clk)
        $rose(rst_n) |-> tx;
    endproperty
    a_reset_tx_high: assert property (p_reset_tx_high)
        else $error("[SVA FAIL] TX not HIGH after reset at time %0t", $time);

    // ---- 6. tx_busy deasserts after completion ----
    property p_busy_falls;
        @(posedge clk) disable iff (!rst_n)
        tx_busy |-> ##[1:5000] !tx_busy;
    endproperty
    a_busy_falls: assert property (p_busy_falls)
        else $error("[SVA FAIL] tx_busy stuck high at time %0t", $time);

    // ---- Coverage properties ----
    cp_parity_err_seen: cover property (
        @(posedge clk) disable iff (!rst_n) parity_err);

    cp_frame_err_seen: cover property (
        @(posedge clk) disable iff (!rst_n) frame_err);

    cp_rx_valid_seen: cover property (
        @(posedge clk) disable iff (!rst_n) rx_valid);

    cp_all_ff: cover property (
        @(posedge clk) disable iff (!rst_n) (rx_valid && rx_data == 8'hFF));

    cp_all_00: cover property (
        @(posedge clk) disable iff (!rst_n) (rx_valid && rx_data == 8'h00));

endmodule : uart_assertions
