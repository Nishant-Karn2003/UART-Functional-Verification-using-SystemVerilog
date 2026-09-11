// ============================================================
// Class     : uart_transaction
// Project   : UART Functional Verification using SystemVerilog
// Description: Constrained-random transaction object
//              Represents one complete UART frame
// ============================================================

class uart_transaction;

    // ---- Randomizable fields ----
    rand bit [7:0] data;          // 8-bit payload
    rand bit       parity_en;     // Enable parity bit
    rand bit       parity_type;   // 0 = even, 1 = odd
    rand int       baud_rate;     // Baud rate selection
    rand int       idle_cycles;   // Idle gap between packets

    // ---- Non-random fields (set by scoreboard/monitor) ----
    bit [7:0] received_data;
    bit       parity_err_seen;
    bit       frame_err_seen;
    bit       passed;

    // ---- Constraints ----

    // Only supported baud rates
    constraint c_baud_rate {
        baud_rate inside {9600, 19200, 38400, 57600, 115200, 230400};
    }

    // Bias data toward boundary values for corner case coverage
    constraint c_data_distribution {
        data dist {
            8'h00           := 5,   // All zeros
            8'hFF           := 5,   // All ones
            [8'h01:8'h7F]   := 45,  // Lower half
            [8'h80:8'hFE]   := 45   // Upper half
        };
    }

    // Idle gap: 0 to 20 clock cycles between packets
    constraint c_idle {
        idle_cycles inside {[0:20]};
    }

    // Parity enabled 70% of the time
    constraint c_parity_weight {
        parity_en dist {1'b1 := 70, 1'b0 := 30};
    }

    // ---- Display ----
    function void display(string tag = "TX");
        $display("[%0t] [%s] data=0x%0h  parity_en=%0b  parity_type=%0b  baud=%0d  idle=%0d",
                 $time, tag, data, parity_en, parity_type, baud_rate, idle_cycles);
    endfunction

    // ---- Copy ----
    function uart_transaction copy();
        uart_transaction t = new();
        t.data          = this.data;
        t.parity_en     = this.parity_en;
        t.parity_type   = this.parity_type;
        t.baud_rate     = this.baud_rate;
        t.idle_cycles   = this.idle_cycles;
        return t;
    endfunction

    // ---- Compare ----
    function bit compare(uart_transaction other);
        return (this.data       === other.data       &&
                this.parity_en  === other.parity_en  &&
                this.parity_type === other.parity_type);
    endfunction

endclass : uart_transaction
