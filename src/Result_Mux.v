`timescale 1ns / 1ps

/*
 * RISC-V 5-Stage Pipelined Processor
 * Copyright (c) 2024 Salman
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */

module Result_Mux (
		   input wire [31:0]  ALUResult,ReadData,PC_Plus_4,
		   input wire [1:0]   ResultSrc,   // Changed from [31:0] to [1:0]
		   output wire [31:0] Result
		   );

   assign Result = ResultSrc[1] ? PC_Plus_4 :(ResultSrc[0] ? ReadData : ALUResult);

endmodule