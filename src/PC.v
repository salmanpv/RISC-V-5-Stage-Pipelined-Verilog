/*
 * RISC-V 5-Stage Pipelined Processor
 * Copyright (c) 2026 Salmanul Faris PV
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */

module PC (
    input wire        clk, reset,
    input wire        StallF,
    input wire [31:0] PCNext,
    output reg  [31:0] PC
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'b0;
        else if (!StallF)
            PC <= PCNext;
    end
endmodule