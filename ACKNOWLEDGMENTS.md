# Acknowledgments

## Original Work

This 5-stage pipelined RISC-V processor is built upon and extends the **RISC-V Single Cycle Processor** by **Govardhan**.

**Original Repository:** [RISCV_Single_Cycle_Processor](https://github.com/govardhnn/RISCV_Single_Cycle_Processor)

**License:** MIT License (Copyright (c) 2023 Govardhan)

### Modifications and Extensions

The pipelined version extends the original single-cycle design with:
- 5-stage pipeline architecture (IF, ID, EX, MEM, WB)
- Data hazard detection and forwarding unit
- Control hazard handling with hazard unit
- Pipeline registers between stages

## Reference Materials

The original single-cycle processor design was based on:
- **"Digital Design and Computer Architecture: RISC-V Edition"** by Sarah L. Harris and David Harris

## License

This project is released under the MIT License. See [LICENSE](LICENSE) file for details.

### Attribution Requirements

When using this code, please include:
1. A copy of the MIT License
2. Credit to Govardhan's original single-cycle processor
3. Notice of any modifications made
