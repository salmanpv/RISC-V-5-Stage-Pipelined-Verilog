`timescale 1ns / 1ps

/*
 * RISC-V 5-Stage Pipelined Processor
 * Copyright (c) 2026 Salmanul Faris PV
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */

module Data_Memory(
		   input wire 	      clk, WE,
		   input wire [31:0]  A, WD,
		   output wire [31:0] RD
		   );

   reg [31:0] 			      RAM[63:0];

   assign RD = RAM[A[31:2]]; // word aligned

   always @(posedge clk)
     if (WE)
       RAM[A[31:2]] <= WD;

endmodule

// Byte addresses 0, 1, 2, 3 all map to word index 0

// Byte addresses 4, 5, 6, 7 map to word index 1

// Byte addresses 8, 9, 10, 11 map to word index 2

// Byte addresses 100 maps to word index 25 (100/4 = 25)