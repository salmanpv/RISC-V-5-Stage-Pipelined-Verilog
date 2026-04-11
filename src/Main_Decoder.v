`timescale 1ns / 1ps
/*
 * RISC-V 5-Stage Pipelined Processor
 * Copyright (c) 2024 Salman
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */
module Main_Decoder(
    input wire [6:0] op,
    output wire [1:0] ResultSrc,
    output wire MemWrite, Branch, ALUSrc, RegWrite, Jump,
    output wire [1:0] ImmSrc, ALUop,
    output wire MemRead   // new output
);

    reg [11:0] control_signals; // expanded by 1 bit

    always @(*) begin
        case(op)
            7'b0000011: control_signals = 12'b1_00_1_0_01_0_00_0_1; // lw
            7'b0100011: control_signals = 12'b0_01_1_1_00_0_00_0_0; // sw
            7'b0110011: control_signals = 12'b1_xx_0_0_00_0_10_0_0; // R-type
            7'b0010011: control_signals = 12'b1_00_1_0_00_0_10_0_0; // I-type ALU
            7'b1100011: control_signals = 12'b0_10_0_0_00_1_01_0_0; // beq
            7'b1101111: control_signals = 12'b1_11_0_0_10_0_00_1_0; // jal
            7'b1100111: control_signals = 12'b1_00_1_0_10_0_00_1_0; // jalr
            7'b0110111: control_signals = 12'b1_00_1_0_00_0_11_0_0; // lui
            7'b0010111: control_signals = 12'b1_00_1_0_00_0_01_0_0; // auipc
            7'b0000000: control_signals = 12'b0_00_0_0_00_0_00_0_0; // reset
            default:    control_signals = 12'bx_xx_x_x_xx_x_xx_x_x;
        endcase
    end

    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUop, Jump, MemRead} = control_signals;

endmodule
