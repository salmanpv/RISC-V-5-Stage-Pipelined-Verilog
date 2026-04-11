`timescale 1ns / 1ps

/*
 * RISC-V 5-Stage Pipelined Processor
 * Copyright (c) 2026 Salmanul Faris PV
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */

module MEM_WB_Pipeline (
    input  wire        clk, reset,
    input  wire [31:0] ALUResult_M, ReadData_M, PCPlus4_M,
    input  wire [4:0]  Rd_M,
    input  wire [1:0]  ResultSrc_M,
    input  wire        RegWrite_M,
    output reg  [31:0] ALUResult_W, ReadData_W, PCPlus4_W,
    output reg  [4:0]  Rd_W,
    output reg  [1:0]  ResultSrc_W,
    output reg        RegWrite_W
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ALUResult_W <= 32'b0;
            ReadData_W  <= 32'b0;
            PCPlus4_W   <= 32'b0;
            Rd_W        <= 5'b0;
            ResultSrc_W <= 2'b0;
            RegWrite_W  <= 1'b0;
        end else begin
            ALUResult_W <= ALUResult_M;
            ReadData_W  <= ReadData_M;
            PCPlus4_W   <= PCPlus4_M;
            Rd_W        <= Rd_M;
            ResultSrc_W <= ResultSrc_M;
            RegWrite_W  <= RegWrite_M;
        end
    end
endmodule