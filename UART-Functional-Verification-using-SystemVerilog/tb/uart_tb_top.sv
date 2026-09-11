// ============================================================
// Module    : uart_tb_top
// Project   : UART Functional Verification using SystemVerilog
// Description: Top-level testbench — instantiates DUT and env,
//              connects via virtual interface, runs tests
// ============================================================

`timescale 1ns/1ps

`include "uart_env.sv"

module uart_tb_top;

    // ---- Parameters ----
    parameter int CLK_FREQ  = 50_000_000;
    parameter int BAUD_RATE = 115200;
    parameter int NUM_TXN   = 200;

    // ---- Clock and reset ----
    logic clk;
    logic rst_n;

    // ---- Interface ----
    uart_if dut_if (.clk(clk), .rst_n(rst_n));

    // ---- DUT instantiation ----
    uart_top #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .tx_start   (dut_if.tx_start),
        .tx_data    (dut_if.tx_data),
        .parity_en  (dut_if.parity_en),
        .parity_type(dut_if.parity_type),
        .tx         (dut_if.tx),
        .tx_busy    (dut_if.tx_busy),
        .rx         (dut_if.tx),      // Loopback: TX → RX
        .rx_data    (dut_if.rx_data),
        .rx_valid   (dut_if.rx_valid),
        .parity_err (dut_if.parity_err),
        .frame_err  (dut_if.frame_err)
    );

    // ---- Assertion module bind ----
    uart_assertions u_assert (
        .clk       (clk),
        .rst_n     (rst_n),
        .tx        (dut_if.tx),
        .rx        (dut_if.tx),
        .tx_start  (dut_if.tx_start),
        .tx_busy   (dut_if.tx_busy),
        .rx_data   (dut_if.rx_data),
        .rx_valid  (dut_if.rx_valid),
        .parity_err(dut_if.parity_err),
        .frame_err (dut_if.frame_err)
    );

    // ---- Clock generation: 50 MHz ----
    initial clk = 1'b0;
    always #10 clk = ~clk;  // 20ns period = 50 MHz

    // ---- Environment ----
    uart_env env;

    // ---- Test stimulus ----
    initial begin
        $display("============================================================");
        $display("  UART FUNCTIONAL VERIFICATION - SystemVerilog Testbench");
        $display("  CLK_FREQ=%0d Hz  BAUD_RATE=%0d  NUM_TXN=%0d",
                 CLK_FREQ, BAUD_RATE, NUM_TXN);
        $display("============================================================\n");

        // Reset sequence
        rst_n = 1'b0;
        repeat(10) @(posedge clk);
        rst_n = 1'b1;
        repeat(5) @(posedge clk);

        // Create and run environment
        env = new(dut_if, NUM_TXN);
        env.run();

        $display("\n[TOP] Simulation complete.");
        $finish;
    end

    // ---- Timeout watchdog ----
    initial begin
        #50_000_000;  // 50ms timeout
        $error("[TOP] TIMEOUT: Simulation exceeded 50ms limit");
        $finish;
    end

    // ---- Waveform dump ----
    initial begin
        $dumpfile("uart_sim.vcd");
        $dumpvars(0, uart_tb_top);
    end

endmodule : uart_tb_top
