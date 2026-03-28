# Makefile for RISC-V Pipelined Processor Simulation
# Requires iverilog and vvp (Icarus Verilog) installed.
# Optional: gtkwave for viewing waveforms.

# Simulator
SIM = iverilog
SIM_FLAGS = -g2012
VVP = vvp

# Output files
VVP_OUT = sim.vvp
VCD_FILE = pipelined_debug.vcd

# All Verilog source files for the pipelined processor
SRCS = ALU.v \
       ALU_Decoder.v \
       ALU_Mux.v \
       Control_Unit.v \
       Core_Datapath.v \
       Data_Memory.v \
       Extend.v \
       Instruction_Memory.v \
       Main_Decoder.v \
       PC.v \
       PC_Mux.v \
       PC_Plus_4.v \
       PC_Target.v \
       Register_File.v \
       Result_Mux.v \
       IF_ID_Pipeline.v \
       ID_EX_Pipeline.v \
       EX_MEM_Pipeline.v \
       MEM_WB_Pipeline.v \
       Hazard_Unit.v \
       Forwarding_Unit.v \
       Pipelined_Core.v \
       Pipelined_Top.v \
       Pipelined_TB.v

# Default target: compile and run simulation
all: simulate

# Compile all sources into a simulation executable
$(VVP_OUT): $(SRCS) instructions.txt
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
	rm -f $(VVP_OUT) $(VCD_FILE) *.vcd

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