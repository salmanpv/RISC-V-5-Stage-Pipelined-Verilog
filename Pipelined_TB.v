`timescale 1ns / 1ps

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
        dump_pipeline_state();
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

    // ------------------------------------------------------------------
    // Helper tasks
    // ------------------------------------------------------------------

    task dump_pipeline_state;
        reg [31:0] PC_val;
        reg        StallF, StallD, FlushD, FlushE, PCSrcE;
        reg [31:0] PC_F, PC_D, Instr_F, Instr_D;
        reg [31:0] PC_E, RD1_E, RD2_E, ImmExt_E;
        reg [3:0]  ALUControl_E;
        reg [31:0] ALUResult_E;
        reg        BranchE, JumpE, MemReadE, MemWriteE, ALUSrcE, RegWriteE;
        reg [4:0]  RdE;
        reg [31:0] ALUResult_M, WriteData_M;
        reg        MemWriteM, RegWriteM;
        reg [4:0]  RdM;
        reg [31:0] ALUResult_W, ReadData_W;
        reg        RegWriteW;
        reg [4:0]  RdW;
        reg [31:0] ResultW;
        reg        branch_taken, jump_taken;
        reg        lwStall;
        reg        ZeroE;

        // Temporary strings for register names
        reg [63:0] id_ex_str, ex_mem_str, mem_wb_str;

        // Extract signals using hierarchical paths to submodules
        PC_val      = DUT.core.PC;
        StallF      = DUT.core.StallF;
        StallD      = DUT.core.StallD;
        FlushD      = DUT.core.FlushD;
        FlushE      = DUT.core.FlushE;
        PCSrcE      = DUT.core.PCSrcE;

        PC_F        = DUT.core.PC_F;
        Instr_F     = DUT.Instr;
        PC_D        = DUT.core.PC_D;
        Instr_D     = DUT.core.Instr_D;

        // ID/EX pipeline register outputs
        PC_E        = DUT.core.id_ex.PC_E;
        RD1_E       = DUT.core.id_ex.RD1_E;
        RD2_E       = DUT.core.id_ex.RD2_E;
        ImmExt_E    = DUT.core.id_ex.ImmExt_E;
        ALUControl_E= DUT.core.id_ex.ALUControl_E;
        BranchE     = DUT.core.id_ex.Branch_E;
        JumpE       = DUT.core.id_ex.Jump_E;
        MemReadE    = DUT.core.id_ex.MemRead_E;
        MemWriteE   = DUT.core.id_ex.MemWrite_E;
        ALUSrcE     = DUT.core.id_ex.ALUSrc_E;
        RegWriteE   = DUT.core.id_ex.RegWrite_E;
        RdE         = DUT.core.id_ex.Rd_E;

        // EX/MEM pipeline register outputs
        ALUResult_M = DUT.core.ex_mem.ALUResult_M;
        WriteData_M = DUT.core.ex_mem.WriteData_M;
        MemWriteM   = DUT.core.ex_mem.MemWrite_M;
        RegWriteM   = DUT.core.ex_mem.RegWrite_M;
        RdM         = DUT.core.ex_mem.Rd_M;

        // MEM/WB pipeline register outputs
        ALUResult_W = DUT.core.mem_wb.ALUResult_W;
        ReadData_W  = DUT.core.mem_wb.ReadData_W;
        RegWriteW   = DUT.core.mem_wb.RegWrite_W;
        RdW         = DUT.core.mem_wb.Rd_W;

        // Result mux output (WB)
        ResultW     = DUT.core.ResultW;

        // ALU zero flag
        ZeroE       = DUT.core.alu.Zero;

        branch_taken = BranchE & ZeroE;
        jump_taken   = JumpE;
        lwStall      = MemReadE && (RdE == DUT.core.Rs1D || RdE == DUT.core.Rs2D);



        $display("=== CYCLE %0d ==================================", cycle);
        $display("--- PIPELINE STATE ---");


        // IF stage
        $display("[IF] PC: 0x%08h -> Instr: 0x%08h", PC_F, Instr_F);

        // ID stage
        if (Instr_D == 32'h00000013) begin
            $display("[ID] NOP");
        end else begin
            decode_instruction(Instr_D, PC_D);
        end

        // EX stage
        if (RegWriteE == 0 && ALUControl_E == 4'b0000 && RD1_E == 0 && RD2_E == 0 && ALUResult_E == 0) begin
            $display("[EX] NOP");
        end else begin
            $display("[EX] rd:x%0d | A:0x%08d | B:0x%08d | Op: %s | Result: 0x%08d",
                     RdE, RD1_E, RD2_E, alu_op_string(ALUControl_E), ALUResult_E);
        end

        // MEM stage
        if (MemWriteM) begin
            $display("[MEM] STORE | Addr:0x%08d <- Data:0x%08d", ALUResult_M, WriteData_M);
        end else if (MemReadE) begin
            $display("[MEM] LOAD  | Addr:0x%08d -> Data:0x%08d", ALUResult_M, ReadData_W);
        end else begin
            $display("[MEM] NOP");
        end

        // WB stage
        if (RegWriteW && RdW != 0) begin
            $display("[WB] x%0d <- 0x%08d", RdW, ResultW);
        end else begin
            $display("[WB] NOP");
        end

        // Hazard/control messages
        if (lwStall) begin
            $display("[STALL] Freezing pipeline for load-use hazard");
        end
        if (branch_taken || jump_taken) begin
            $display("[CONTROL] Branch/Jump taken -> PC: 0x%08h, flushing pipeline",
                     (branch_taken ? PC_E + ImmExt_E : PC_E + ImmExt_E));
        end
        if (FlushD || FlushE) begin
            $display("[FLUSH] Flushing pipeline");
        end

        $display("");
    endtask

    // Decode instruction and print relevant fields
    task decode_instruction;
        input [31:0] instr;
        input [31:0] pc_val;
        reg [6:0] opcode;
        reg [2:0] funct3;
        reg [6:0] funct7;
        reg [4:0] rs1, rs2, rd;
        reg [31:0] imm;
        reg [3:0] alu_control;
        reg reg_write, mem_read, mem_write, mem_to_reg, alu_src, branch, jump;
        string op_name;

        opcode = instr[6:0];
        funct3 = instr[14:12];
        funct7 = instr[31:25];
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        rd  = instr[11:7];

        // Extract immediate depending on opcode
        case (opcode)
            7'b0000011: imm = {{20{instr[31]}}, instr[31:20]};  // I-type load
            7'b0010011: imm = {{20{instr[31]}}, instr[31:20]};  // I-type ALU
            7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
            7'b0110011: imm = 0;                                 // R-type
            7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
            7'b1101111: imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type
            7'b0110111: imm = {instr[31:12], 12'b0};             // U-type lui
            7'b0010111: imm = {instr[31:12], 12'b0};             // U-type auipc
            default:    imm = 0;
        endcase

        // Determine ALU control (simplified)
        alu_control = 4'b0000;
        case (opcode)
            7'b0110011: begin  // R-type
                if (funct7 == 7'b0000000) begin
                    case (funct3)
                        3'b000: alu_control = 4'b0000; // add
                        3'b001: alu_control = 4'b1010; // sll
                        3'b010: alu_control = 4'b0101; // slt
                        3'b011: alu_control = 4'b0110; // sltu
                        3'b100: alu_control = 4'b0100; // xor
                        3'b101: alu_control = (funct7[5] ? 4'b1011 : 4'b1100); // sra / srl
                        3'b110: alu_control = 4'b0011; // or
                        3'b111: alu_control = 4'b0010; // and
                    endcase
                end else if (funct7 == 7'b0100000 && funct3 == 3'b000) begin
                    alu_control = 4'b0001; // sub
                end
            end
            7'b0010011: begin  // I-type ALU
                case (funct3)
                    3'b000: alu_control = 4'b0000; // addi
                    3'b001: alu_control = 4'b1010; // slli
                    3'b010: alu_control = 4'b0101; // slti
                    3'b011: alu_control = 4'b0110; // sltui
                    3'b100: alu_control = 4'b0100; // xori
                    3'b101: alu_control = (funct7[5] ? 4'b1011 : 4'b1100); // srai / srli
                    3'b110: alu_control = 4'b0011; // ori
                    3'b111: alu_control = 4'b0010; // andi
                endcase
            end
            7'b0000011: alu_control = 4'b0000; // lw (add)
            7'b0100011: alu_control = 4'b0000; // sw (add)
            7'b1100011: alu_control = 4'b0001; // beq (subtract)
            7'b0110111: alu_control = 4'b1001; // lui (special)
            7'b0010111: alu_control = 4'b1000; // auipc
            default: alu_control = 4'b0000;
        endcase

        // Determine control signals (simplified)
        reg_write = (opcode == 7'b0110011 || opcode == 7'b0010011 || opcode == 7'b0000011 ||
                     opcode == 7'b0110111 || opcode == 7'b0010111 || opcode == 7'b1101111 ||
                     opcode == 7'b1100111);
        mem_read  = (opcode == 7'b0000011);
        mem_write = (opcode == 7'b0100011);
        mem_to_reg = (opcode == 7'b0000011);
        alu_src   = (opcode == 7'b0010011 || opcode == 7'b0000011 || opcode == 7'b0100011 ||
                     opcode == 7'b0110111 || opcode == 7'b0010111);
        branch    = (opcode == 7'b1100011);
        jump      = (opcode == 7'b1101111 || opcode == 7'b1100111);

        op_name = alu_op_string(alu_control);

        $display("[ID] Instr: 0x%08h | Op: %b | rd:x%0d | rs1:x%0d | rs2:x%0d",
                 instr, opcode, rd, rs1, rs2);
        $display("     Imm: 0x%08d", imm);
        $display("     Ctrl: Ctrl { regWrite: %b, memRead: %b, memWrite: %b, memToReg: %b, aluSrc: %b, branch: %b, jump: %b }",
                 reg_write, mem_read, mem_write, mem_to_reg, alu_src, branch, jump);
        $display("     ALU Operation: %s", op_name);
    endtask

    // Map ALUControl to string
    function string alu_op_string;
        input [3:0] alu_control;
        begin
            case (alu_control)
                4'b0000: alu_op_string = "ALU_ADD";
                4'b0001: alu_op_string = "ALU_SUB";
                4'b0010: alu_op_string = "ALU_AND";
                4'b0011: alu_op_string = "ALU_OR";
                4'b0100: alu_op_string = "ALU_XOR";
                4'b0101: alu_op_string = "ALU_SLT";
                4'b0110: alu_op_string = "ALU_SLTU";
                4'b1000: alu_op_string = "AUIPC";
                4'b1001: alu_op_string = "LUI";
                4'b1010: alu_op_string = "SLL";
                4'b1011: alu_op_string = "SRA";
                4'b1100: alu_op_string = "SRL";
                default: alu_op_string = "???";
            endcase
        end
    endfunction

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