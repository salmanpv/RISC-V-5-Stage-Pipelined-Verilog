# RISC-V 5-Stage Pipelined CPU

A 5-stage pipelined RISC-V processor written in Verilog.

This project extends the RISC-V Single Cycle Processor by Govardhan with pipelining, hazard detection, and forwarding.

## Acknowledgments

**Built upon:** [RISC-V Single Cycle Processor by Govardhan](https://github.com/GovardhananKA/RISCV_Single_Cycle_Processor)
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

