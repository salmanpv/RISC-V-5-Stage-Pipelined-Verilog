`timescale 1ns / 1ps

/*
 * RISC-V 5-Stage Pipelined Processor
 * Copyright (c) 2026 Salmanul Faris PV
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */

module EX_MEM_Pipeline (
    input  wire        clk, reset,
    input  wire [31:0] ALUResult_E, WriteData_E, PCPlus4_E,
    input  wire [4:0]  Rd_E,
    input  wire [1:0]  ResultSrc_E,
    input  wire        MemWrite_E, RegWrite_E,
    output reg  [31:0] ALUResult_M, WriteData_M, PCPlus4_M,
    output reg  [4:0]  Rd_M,
    output reg  [1:0]  ResultSrc_M,
    output reg        MemWrite_M, RegWrite_M
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ALUResult_M <= 32'b0;
            WriteData_M <= 32'b0;
            PCPlus4_M   <= 32'b0;
            Rd_M        <= 5'b0;
            ResultSrc_M <= 2'b0;
            MemWrite_M  <= 1'b0;
            RegWrite_M  <= 1'b0;
        end else begin
            ALUResult_M <= ALUResult_E;
            WriteData_M <= WriteData_E;
            PCPlus4_M   <= PCPlus4_E;
            Rd_M        <= Rd_E;
            ResultSrc_M <= ResultSrc_E;
            MemWrite_M  <= MemWrite_E;
            RegWrite_M  <= RegWrite_E;
        end
    end
endmodule