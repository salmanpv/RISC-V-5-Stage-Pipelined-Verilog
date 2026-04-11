`timescale 1ns / 1ps

/*
 * RISC-V 5-Stage Pipelined Processor
 * Copyright (c) 2026 Salmanul Faris PV
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */

module ID_EX_Pipeline (
    input  wire        clk, reset,
    input  wire        FlushE, StallD,
    input  wire [31:0] PC_D, PCPlus4_D, ImmExt_D, RD1_D, RD2_D,
    input  wire [4:0]  Rs1_D, Rs2_D, Rd_D,
    input  wire [1:0]  ResultSrc_D,
    input  wire        MemWrite_D, Branch_D, ALUSrc_D, RegWrite_D, Jump_D, MemRead_D,
    input  wire [3:0]  ALUControl_D,
    output reg  [31:0] PC_E, PCPlus4_E, ImmExt_E, RD1_E, RD2_E,
    output reg  [4:0]  Rs1_E, Rs2_E, Rd_E,
    output reg  [1:0]  ResultSrc_E,
    output reg        MemWrite_E, Branch_E, ALUSrc_E, RegWrite_E, Jump_E, MemRead_E,
    output reg  [3:0]  ALUControl_E
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_E        <= 32'b0;
            PCPlus4_E   <= 32'b0;
            ImmExt_E    <= 32'b0;
            RD1_E       <= 32'b0;
            RD2_E       <= 32'b0;
            Rs1_E       <= 5'b0;
            Rs2_E       <= 5'b0;
            Rd_E        <= 5'b0;
            ResultSrc_E <= 2'b0;
            MemWrite_E  <= 1'b0;
            Branch_E    <= 1'b0;
            ALUSrc_E    <= 1'b0;
            RegWrite_E  <= 1'b0;
            Jump_E      <= 1'b0;
            MemRead_E   <= 1'b0;
            ALUControl_E<= 4'b0;
        end else if (FlushE) begin
            // flush: set control signals to 0, bubble
            PC_E        <= 32'b0;
            PCPlus4_E   <= 32'b0;
            ImmExt_E    <= 32'b0;
            RD1_E       <= 32'b0;
            RD2_E       <= 32'b0;
            Rs1_E       <= 5'b0;
            Rs2_E       <= 5'b0;
            Rd_E        <= 5'b0;
            ResultSrc_E <= 2'b0;
            MemWrite_E  <= 1'b0;
            Branch_E    <= 1'b0;
            ALUSrc_E    <= 1'b0;
            RegWrite_E  <= 1'b0;
            Jump_E      <= 1'b0;
            MemRead_E   <= 1'b0;
            ALUControl_E<= 4'b0;
        end else if (StallD) begin
            // stall: hold previous values (no change)
            // inputs from ID are unchanged because ID stage is frozen
            // so we simply don't update, i.e., keep the same values
        end else begin
            PC_E        <= PC_D;
            PCPlus4_E   <= PCPlus4_D;
            ImmExt_E    <= ImmExt_D;
            RD1_E       <= RD1_D;
            RD2_E       <= RD2_D;
            Rs1_E       <= Rs1_D;
            Rs2_E       <= Rs2_D;
            Rd_E        <= Rd_D;
            ResultSrc_E <= ResultSrc_D;
            MemWrite_E  <= MemWrite_D;
            Branch_E    <= Branch_D;
            ALUSrc_E    <= ALUSrc_D;
            RegWrite_E  <= RegWrite_D;
            Jump_E      <= Jump_D;
            MemRead_E   <= MemRead_D;
            ALUControl_E<= ALUControl_D;
        end
    end
endmodule