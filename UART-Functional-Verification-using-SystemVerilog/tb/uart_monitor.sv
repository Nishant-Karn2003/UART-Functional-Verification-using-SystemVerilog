// ============================================================
// Class     : uart_monitor
// Project   : UART Functional Verification using SystemVerilog
// Description: Passively observes RX output of DUT, reconstructs
//              received frame and sends to scoreboard
// ============================================================

class uart_monitor;

    virtual uart_if.MONITOR vif;
    mailbox #(uart_transaction) mon2scb;

    int tx_count;
    int rx_count;

    // ---- Constructor ----
    function new(virtual uart_if.MONITOR vi,
                 mailbox #(uart_transaction) mb);
        vif      = vi;
        mon2scb  = mb;
        tx_count = 0;
        rx_count = 0;
    endfunction

    // ---- Monitor RX valid pulses ----
    task run();
        uart_transaction txn;
        $display("[%0t] [MON] Started", $time);

        forever begin
            // Wait for rx_valid pulse
            @(posedge vif.clk iff vif.monitor_cb.rx_valid);

            txn                = new();
            txn.received_data  = vif.monitor_cb.rx_data;
            txn.parity_err_seen = vif.monitor_cb.parity_err;
            txn.frame_err_seen  = vif.monitor_cb.frame_err;

            rx_count++;
            $display("[%0t] [MON] Received data=0x%0h  parity_err=%0b  frame_err=%0b  [RX#%0d]",
                     $time, txn.received_data, txn.parity_err_seen, txn.frame_err_seen, rx_count);

            mon2scb.put(txn);
        end
    endtask

endclass : uart_monitor
