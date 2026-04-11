`timescale 1ns / 1ps

/*
 * RISC-V 5-Stage Pipelined Processor
 * Copyright (c) 2024 Salman
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */

module ALU_Mux (
		input wire [31:0]  WD, ImmExt,
		input wire	   ALUSrc,
		output wire [31:0] B
		);

   assign B = ALUSrc ? ImmExt : WD;

endmodule
