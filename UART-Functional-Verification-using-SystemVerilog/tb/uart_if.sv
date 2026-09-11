// ============================================================
// Interface : uart_if
// Project   : UART Functional Verification using SystemVerilog
// Description: Virtual interface encapsulating all UART signals
//              used by driver, monitor, and testbench
// ============================================================

interface uart_if (input logic clk, input logic rst_n);

    // ---- DUT signal ports ----
    logic       tx_start;
    logic [7:0] tx_data;
    logic       parity_en;
    logic       parity_type;
    logic       tx;
    logic       tx_busy;
    logic       rx;
    logic [7:0] rx_data;
    logic       rx_valid;
    logic       parity_err;
    logic       frame_err;

    // ---- Clocking block (driver side) ----
    clocking driver_cb @(posedge clk);
        default input  #1 output #1;
        output tx_start;
        output tx_data;
        output parity_en;
        output parity_type;
        input  tx_busy;
        input  tx;
    endclocking

    // ---- Clocking block (monitor side) ----
    clocking monitor_cb @(posedge clk);
        default input #1;
        input tx;
        input rx;
        input rx_data;
        input rx_valid;
        input parity_err;
        input frame_err;
        input tx_busy;
    endclocking

    // ---- Modports ----
    modport DRIVER  (clocking driver_cb,  input clk, input rst_n);
    modport MONITOR (clocking monitor_cb, input clk, input rst_n);
    modport DUT     (
        input  clk, rst_n, tx_start, tx_data, parity_en, parity_type, rx,
        output tx, tx_busy, rx_data, rx_valid, parity_err, frame_err
    );

endinterface : uart_if
