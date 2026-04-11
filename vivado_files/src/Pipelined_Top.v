module Pipelined_Top (
    input  wire        clk, reset,
    output wire [31:0] WriteData, DataAddr,
    output wire        MemWrite
);

    wire [31:0] PC, Instr, ReadData;

    Pipelined_Core core (
        .clk(clk),
        .reset(reset),
        .Instr(Instr),
        .ReadData(ReadData),
        .PC(PC),
        .MemWrite(MemWrite),
        .ALUResult(DataAddr),
        .WriteData(WriteData)
    );

    Instruction_Memory imem (
        .A(PC),
        .RD(Instr)
    );

    Data_Memory dmem (
        .clk(clk),
        .WE(MemWrite),
        .A(DataAddr),
        .WD(WriteData),
        .RD(ReadData)
    );

endmodule