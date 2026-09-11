// ============================================================
// Class     : uart_scoreboard
// Project   : UART Functional Verification using SystemVerilog
// Description: Self-checking scoreboard — compares transmitted
//              transactions with received frame data
// ============================================================

class uart_scoreboard;

    mailbox #(uart_transaction) drv2scb;   // From driver (what was sent)
    mailbox #(uart_transaction) mon2scb;   // From monitor (what was received)

    int pass_count;
    int fail_count;
    int total_count;

    // ---- Constructor ----
    function new(mailbox #(uart_transaction) drv_mb,
                 mailbox #(uart_transaction) mon_mb);
        drv2scb     = drv_mb;
        mon2scb     = mon_mb;
        pass_count  = 0;
        fail_count  = 0;
        total_count = 0;
    endfunction

    // ---- Compare one transaction pair ----
    task check_one();
        uart_transaction sent, received;

        drv2scb.get(sent);
        mon2scb.get(received);
        total_count++;

        // Data match check
        if (sent.data !== received.received_data) begin
            $error("[SCB][FAIL #%0d] Data mismatch! Sent=0x%0h  Got=0x%0h",
                   total_count, sent.data, received.received_data);
            fail_count++;
        end
        // Parity error check (none expected on clean transmission)
        else if (received.parity_err_seen && sent.parity_en) begin
            $error("[SCB][FAIL #%0d] Unexpected parity error! data=0x%0h", total_count, sent.data);
            fail_count++;
        end
        // Frame error check
        else if (received.frame_err_seen) begin
            $error("[SCB][FAIL #%0d] Frame error detected! data=0x%0h", total_count, sent.data);
            fail_count++;
        end
        else begin
            $display("[SCB][PASS #%0d] data=0x%0h  parity_en=%0b  parity_type=%0b",
                     total_count, sent.data, sent.parity_en, sent.parity_type);
            pass_count++;
        end
    endtask

    // ---- Main run loop ----
    task run();
        $display("[%0t] [SCB] Running...", $time);
        forever begin
            check_one();
        end
    endtask

    // ---- Final report ----
    function void report();
        $display("\n");
        $display("============================================================");
        $display("  UART VERIFICATION REPORT");
        $display("============================================================");
        $display("  Total Transactions : %0d", total_count);
        $display("  PASSED             : %0d", pass_count);
        $display("  FAILED             : %0d", fail_count);
        $display("  Pass Rate          : %0.1f%%", (pass_count * 100.0) / total_count);
        $display("============================================================");
        if (fail_count == 0)
            $display("  *** ALL TESTS PASSED ***");
        else
            $display("  *** %0d TEST(S) FAILED ***", fail_count);
        $display("============================================================\n");
    endfunction

endclass : uart_scoreboard
