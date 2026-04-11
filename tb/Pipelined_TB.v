`timescale 1ns / 1ps

/*
 * RISC-V 5-Stage Pipelined Processor - Testbench
 * Copyright (c) 2026 Salmanul Faris PV
 * Based on RISC-V Single Cycle Processor by Govardhan (2023)
 * 
 * Licensed under MIT License
 * See LICENSE file for full license text
 */

module Pipelined_TB_Debug();

    reg clk = 0, reset;
    wire [31:0] WriteData, DataAddr;
    wire MemWrite;

    // Instantiate the top-level design
    Pipelined_Top DUT (
        .clk(clk),
        .reset(reset),
        .WriteData(WriteData),
        .DataAddr(DataAddr),
        .MemWrite(MemWrite)
    );

    // Generate 10ns clock
    always #10 clk = ~clk;

    // Waveform dump
    initial begin
        $dumpfile("pipelined_debug.vcd");
        $dumpvars(0, DUT);
    end

    // Reset sequence
    initial begin
        #20 reset = 0;
        #20 reset = 1;
        #20 reset = 0;
    end

    // ------------------------------------------------------------------
    // Debug state: print pipeline state on the negative edge of the clock
    // ------------------------------------------------------------------
    integer cycle = 0;

    always @(negedge clk) begin
        cycle = cycle + 1;
    end


    // ------------------------------------------------------------------
    // Timeout
    // ------------------------------------------------------------------
    initial begin
        #1000 $display("\n*** TIMEOUT: Simulation ran for 1000 ns without pass/fail ***\n");
        dump_registers();
        dump_memory(0, 63);
        $stop;
    end

    // Register file dump
    task dump_registers;
        integer i;
        begin
            $display("\n========== REGISTER FILE CONTENTS ==========");
            $display("  x0  : 0x00000000 (0)");
            for (i = 1; i < 32; i = i + 1) begin
                $display("  x%2d : 0x%08h (%0d)", i,
                         DUT.core.regfile.REG_MEM_BLOCK[i],
                         DUT.core.regfile.REG_MEM_BLOCK[i]);
            end
            $display("============================================\n");
        end
    endtask

    // Data memory dump
    task dump_memory;
        input integer start_word;
        input integer end_word;
        integer addr;
        begin
            $display("\n========== DATA MEMORY CONTENTS ==========");
            for (addr = start_word; addr <= end_word; addr = addr + 1) begin
                $display("  [%3d] : 0x%08h (%0d)", addr, DUT.dmem.RAM[addr], DUT.dmem.RAM[addr]);
            end
            $display("===========================================\n");
        end
    endtask

endmodule