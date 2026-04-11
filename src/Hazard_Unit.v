`timescale 1ns / 1ps

/*
 * RISC-V 5-Stage Pipelined Processor
 * Copyright (c) 2024 Salman
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */

module Hazard_Unit (
    input  wire [4:0] Rs1D, Rs2D,
    input  wire [4:0] RdE,
    input  wire       MemReadE,
    input  wire       PCSrcE,
    output wire       StallF,
    output wire       StallD,
    output wire       FlushD,
    output wire       FlushE
);

    wire lwStall;
    assign lwStall = MemReadE && ( (RdE == Rs1D) || (RdE == Rs2D) );

    assign StallF = lwStall;
    assign StallD = lwStall;
    assign FlushD = PCSrcE;
    assign FlushE = lwStall | PCSrcE;

endmodule