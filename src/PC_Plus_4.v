`timescale 1ns / 1ps

/*
 * RISC-V 5-Stage Pipelined Processor
 * Copyright (c) 2024 Salman
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */

module PC_Plus_4(
		 input wire [31:0]  PC,
		 output wire [31:0] PCPlus4 );

   assign PCPlus4 = PC + 32'd4;

endmodule
