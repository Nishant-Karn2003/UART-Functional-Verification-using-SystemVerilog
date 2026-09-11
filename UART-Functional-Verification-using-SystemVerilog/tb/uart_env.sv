// ============================================================
// Class     : uart_env
// Project   : UART Functional Verification using SystemVerilog
// Description: Testbench environment — connects all components:
//              generator, driver, monitor, scoreboard, coverage
// ============================================================

`include "uart_transaction.sv"
`include "uart_generator.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"
`include "uart_scoreboard.sv"
`include "uart_coverage.sv"

class uart_env;

    uart_generator  gen;
    uart_driver     drv;
    uart_monitor    mon;
    uart_scoreboard scb;
    uart_coverage   cov;

    mailbox #(uart_transaction) gen2drv;
    mailbox #(uart_transaction) drv2scb;
    mailbox #(uart_transaction) mon2scb;

    virtual uart_if vif;

    // ---- Constructor ----
    function new(virtual uart_if vi, int unsigned num_txn = 100);
        vif     = vi;

        gen2drv = new();
        drv2scb = new();
        mon2scb = new();

        gen = new(gen2drv, num_txn);
        drv = new(vif,     gen2drv, drv2scb);
        mon = new(vif,     mon2scb);
        scb = new(drv2scb, mon2scb);
        cov = new();
    endfunction

    // ---- Run all components in parallel ----
    task run();
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_any

        @(gen.gen_done);  // Wait for generator to finish
        #10000;           // Drain remaining transactions

        scb.report();
        cov.report();
    endtask

endclass : uart_env
