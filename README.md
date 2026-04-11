# RISC-V 5-Stage Pipelined CPU

A 5-stage pipelined RISC-V processor written in Verilog.

This project extends the RISC-V Single Cycle Processor by Govardhan with pipelining, hazard detection, and forwarding.

## Acknowledgments

**Built upon:** [RISC-V Single Cycle Processor by Govardhan](https://github.com/govardhnn/RISCV_Single_Cycle_Processor)
- Original Reference: "Digital Design and Computer Architecture: RISC-V Edition" by Sarah L. Harris and David Harris
- Licensed under MIT License (See [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md))

## Project Structure

- `src/`: Design RTL files and instruction memory file
- `tb/`: Testbench files
- `Makefile`: Build and simulation targets

## Files

- Design files: `src/*.v`
- Testbench files: `tb/*.v`
- Instruction memory: `src/instructions.mem`

## CPU Technical Details

- ISA base: RV32I subset focused on arithmetic, load/store, branch, and immediate operations.
- Datapath width: 32-bit data path and 32-bit instruction path.
- Pipeline stages:
	- IF: Program counter update and instruction fetch.
	- ID: Instruction decode, register file read, immediate generation, and control generation.
	- EX: ALU execution, branch decision, and forwarding selection.
	- MEM: Data memory read/write.
	- WB: Write-back select (ALU, memory, or PC+4) to register file.
- Pipeline registers: `IF_ID_Pipeline`, `ID_EX_Pipeline`, `EX_MEM_Pipeline`, `MEM_WB_Pipeline` isolate stage timing.
- Hazard handling:
	- Data hazards are resolved using `Forwarding_Unit` (EX/MEM and MEM/WB bypass paths).
	- Load-use hazards are handled in `Hazard_Unit` using stall and flush control.
	- Control hazards are handled by flushing younger instructions on taken branch/jump decisions.
- Branch/control path:
	- Branch compare and target selection are resolved in execute path.
	- `PC` and `PC_Plus_4` modules implement sequential and redirected fetch addresses.
- Core functional blocks:
	- `Main_Decoder` + `ALU_Decoder` generate control signals.
	- `ALU_Mux` selects ALU operand source.
	- `Result_Mux` selects write-back source.
	- `Register_File`, `Instruction_Memory`, and `Data_Memory` implement architectural storage.
- Simulation flow: Icarus Verilog build and testbench-driven waveform generation (`pipelined_debug.vcd`).

## Run Simulation

Requirements:
- Icarus Verilog (`iverilog`, `vvp`)
- Optional: GTKWave (`gtkwave`)

Commands:

```bash
make
make simulate
make wave
make view
make clean
```

## Notes

- The instruction memory is loaded from `src/instructions.mem`.
- Run `make` from the repository root.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

**Attribution:** Built upon Govardhan's RISC-V Single Cycle Processor (2023, MIT License).
For complete acknowledgments, see [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md).

