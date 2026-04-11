`timescale 1ns / 1ps

/*
 * RISC-V 5-Stage Pipelined Processor
 * Copyright (c) 2026 Salmanul Faris PV
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */

module IF_ID_Pipeline (
    input  wire        clk, reset,
    input  wire        StallD, FlushD,
    input  wire [31:0] PC_F, PCPlus4_F, Instr_F,
    output reg  [31:0] PC_D, PCPlus4_D, Instr_D
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_D       <= 32'b0;
            PCPlus4_D  <= 32'b0;
            Instr_D    <= 32'b0;
        end else if (StallD) begin
            // stall: hold previous values (no change)
            PC_D       <= PC_D;
            PCPlus4_D  <= PCPlus4_D;
            Instr_D    <= Instr_D;
        end else if (FlushD) begin
            // flush: clear the instruction (insert bubble)
            PC_D       <= 32'b0;
            PCPlus4_D  <= 32'b0;
            Instr_D    <= 32'b0;
        end else begin
            PC_D       <= PC_F;
            PCPlus4_D  <= PCPlus4_F;
            Instr_D    <= Instr_F;
        end
    end
endmodule