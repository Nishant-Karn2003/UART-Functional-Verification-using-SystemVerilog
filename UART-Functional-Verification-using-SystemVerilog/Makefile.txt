# ============================================================
# Makefile - UART Functional Verification
# Supports: ModelSim (vsim), Icarus Verilog (iverilog)
# ============================================================

RTL_DIR = rtl
TB_DIR  = tb
SIM_DIR = sim

RTL_FILES = $(RTL_DIR)/uart_tx.sv \
            $(RTL_DIR)/uart_rx.sv \
            $(RTL_DIR)/uart_top.sv

TB_FILES  = $(TB_DIR)/uart_if.sv \
            $(TB_DIR)/uart_assertions.sv \
            $(TB_DIR)/uart_tb_top.sv

# ---- ModelSim ----
.PHONY: sim_modelsim
sim_modelsim:
	@echo "=== Running UART Verification on ModelSim ==="
	cd $(SIM_DIR) && vsim -c -do run.do

# ---- Icarus Verilog ----
.PHONY: sim_iverilog
sim_iverilog:
	@echo "=== Compiling with Icarus Verilog ==="
	iverilog -g2012 -I$(TB_DIR) -I$(RTL_DIR) \
	         $(RTL_FILES) $(TB_FILES) \
	         -o $(SIM_DIR)/uart_sim
	@echo "=== Running simulation ==="
	cd $(SIM_DIR) && vvp uart_sim
	@echo "=== Opening waveform ==="
	gtkwave $(SIM_DIR)/uart_sim.vcd &

# ---- Clean ----
.PHONY: clean
clean:
	rm -rf work $(SIM_DIR)/*.vcd $(SIM_DIR)/uart_sim transcript vsim.wlf

# ---- Help ----
.PHONY: help
help:
	@echo "UART Functional Verification Makefile"
	@echo "--------------------------------------"
	@echo "  make sim_modelsim  - Run with ModelSim/QuestaSim"
	@echo "  make sim_iverilog  - Run with Icarus Verilog + GTKWave"
	@echo "  make clean         - Remove build artifacts"
