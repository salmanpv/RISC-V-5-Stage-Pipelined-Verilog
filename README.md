# RISC-V 5-Stage Pipelined CPU

A simple 5-stage pipelined RISC-V processor written in Verilog.

## Project Structure

- `src/`: Design RTL files and instruction memory file
- `tb/`: Testbench files
- `Makefile`: Build and simulation targets

## Files

- Design files: `src/*.v`
- Testbench files: `tb/*.v`
- Instruction memory: `src/instructions.mem`

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
