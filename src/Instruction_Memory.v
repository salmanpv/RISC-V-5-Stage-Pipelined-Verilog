`timescale 1ns / 1ps

/*
 * RISC-V 5-Stage Pipelined Processor
 * Copyright (c) 2026 Salmanul Faris PV
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */

module Instruction_Memory(
			  input [31:0] 	A,
			  output [31:0] RD
			  );

   reg [31:0] I_MEM_BLOCK[0:63];   // Changed from [63:0] to [0:63]

   initial
     begin
    // Keep this relative to repository root where simulation is run
    $readmemh("src/instructions.mem", I_MEM_BLOCK);
     end

   assign RD = I_MEM_BLOCK[A[31:2]]; // word aligned

endmodule