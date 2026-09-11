// ============================================================
// Class     : uart_driver
// Project   : UART Functional Verification using SystemVerilog
// Description: Receives transactions from mailbox and drives
//              the DUT signals via virtual interface
// ============================================================

class uart_driver;

    virtual uart_if.DRIVER vif;
    mailbox #(uart_transaction) gen2drv;
    mailbox #(uart_transaction) drv2scb;   // To scoreboard

    // ---- Constructor ----
    function new(virtual uart_if.DRIVER vi,
                 mailbox #(uart_transaction) mb_in,
                 mailbox #(uart_transaction) mb_out);
        vif     = vi;
        gen2drv = mb_in;
        drv2scb = mb_out;
    endfunction

    // ---- Reset DUT ----
    task reset();
        $display("[%0t] [DRV] Applying reset", $time);
        vif.driver_cb.tx_start   <= 1'b0;
        vif.driver_cb.tx_data    <= 8'h00;
        vif.driver_cb.parity_en  <= 1'b0;
        vif.driver_cb.parity_type <= 1'b0;
        repeat(5) @(vif.driver_cb);
        $display("[%0t] [DRV] Reset done", $time);
    endtask

    // ---- Drive a single transaction ----
    task drive_txn(uart_transaction txn);
        // Wait until DUT is not busy
        while (vif.driver_cb.tx_busy) @(vif.driver_cb);

        // Apply idle gap
        repeat(txn.idle_cycles) @(vif.driver_cb);

        // Drive signals
        @(vif.driver_cb);
        vif.driver_cb.tx_data     <= txn.data;
        vif.driver_cb.parity_en   <= txn.parity_en;
        vif.driver_cb.parity_type <= txn.parity_type;
        vif.driver_cb.tx_start    <= 1'b1;

        @(vif.driver_cb);
        vif.driver_cb.tx_start <= 1'b0;

        // Wait for transmission to complete
        @(posedge vif.clk iff !vif.tx_busy);

        txn.display("DRV");
        drv2scb.put(txn);
    endtask

    // ---- Main run loop ----
    task run();
        uart_transaction txn;
        reset();
        $display("[%0t] [DRV] Running...", $time);
        forever begin
            gen2drv.get(txn);
            drive_txn(txn);
        end
    endtask

endclass : uart_driver
