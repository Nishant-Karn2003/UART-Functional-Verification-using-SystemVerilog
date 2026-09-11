// ============================================================
// Class     : uart_generator
// Project   : UART Functional Verification using SystemVerilog
// Description: Constrained random stimulus generator
//              Sends transactions to driver via mailbox
// ============================================================

class uart_generator;

    int unsigned num_transactions;
    mailbox #(uart_transaction) gen2drv;
    event gen_done;

    // ---- Constructor ----
    function new(mailbox #(uart_transaction) mb, int unsigned n = 100);
        gen2drv          = mb;
        num_transactions = n;
    endfunction

    // ---- Main run task ----
    task run();
        uart_transaction txn;
        $display("[%0t] [GEN] Starting: %0d transactions", $time, num_transactions);

        repeat (num_transactions) begin
            txn = new();
            if (!txn.randomize()) begin
                $error("[GEN] Randomization failed!");
            end else begin
                txn.display("GEN");
                gen2drv.put(txn);
            end
        end

        $display("[%0t] [GEN] Done.", $time);
        ->gen_done;
    endtask

    // ---- Directed test: sweep all 256 data values ----
    task run_directed_sweep();
        uart_transaction txn;
        $display("[%0t] [GEN] Directed sweep: all 256 values", $time);
        for (int i = 0; i < 256; i++) begin
            txn            = new();
            txn.data       = i[7:0];
            txn.parity_en  = 1'b1;
            txn.parity_type = (i % 2);
            txn.baud_rate  = 115200;
            txn.idle_cycles = 2;
            gen2drv.put(txn);
        end
        ->gen_done;
    endtask

endclass : uart_generator
