# Makefile for RISC-V Pipelined Processor Simulation
# Requires iverilog and vvp (Icarus Verilog) installed.
# Optional: gtkwave for viewing waveforms.

# Simulator
SIM = iverilog
SIM_FLAGS = -g2012
VVP = vvp

ifeq ($(OS),Windows_NT)
RM = del /F /Q
else
RM = rm -f
endif

# Output files
VVP_OUT = sim.vvp
VCD_FILE = pipelined_debug.vcd

# Project layout
SRC_DIR = src
TB_DIR = tb
MEM_FILE = $(SRC_DIR)/instructions.mem

# All Verilog source files for the pipelined processor and testbench
DESIGN_SRCS = $(wildcard $(SRC_DIR)/*.v)
TB_SRCS = $(wildcard $(TB_DIR)/*.v)
SRCS = $(DESIGN_SRCS) $(TB_SRCS)

# Default target: compile and run simulation
all: simulate

# Compile all sources into a simulation executable
$(VVP_OUT): $(SRCS) $(MEM_FILE)
	$(SIM) $(SIM_FLAGS) -o $@ $(SRCS)

# Run the simulation (default)
simulate: $(VVP_OUT)
	$(VVP) $(VVP_OUT)

# Run simulation and generate waveform (if testbench has $dumpfile)
wave: $(VVP_OUT)
	$(VVP) $(VVP_OUT) +dumpfile=$(VCD_FILE)

# View waveform with GTKWave (assumes .vcd file exists)
view: wave
	gtkwave $(VCD_FILE)

# Clean up generated files
clean:
	-$(RM) $(VVP_OUT) $(VCD_FILE) *.vcd

# Help message
help:
	@echo "Available targets:"
	@echo "  all        : Compile and run simulation (default)"
	@echo "  simulate   : Run simulation (compiles if needed)"
	@echo "  wave       : Run simulation and generate waveform"
	@echo "  view       : Generate waveform and open GTKWave"
	@echo "  clean      : Remove generated files"
	@echo "  help       : Show this message"

.PHONY: all simulate wave view clean help