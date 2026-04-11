module Pipelined_Core (
    input  wire        clk, reset,
    input  wire [31:0] Instr,
    input  wire [31:0] ReadData,
    output wire [31:0] PC,
    output wire        MemWrite,
    output wire [31:0] ALUResult,
    output wire [31:0] WriteData
);

    // ------------------------------------------------------------------
    // IF stage
    // ------------------------------------------------------------------
    wire [31:0] PC_F, PCPlus4_F;
    wire        StallF, StallD, FlushD, FlushE;
    wire        PCSrcE;
    wire [31:0] PCTarget_E;

    PC pc_inst (
        .clk(clk),
        .reset(reset),
        .StallF(StallF),
        .PCNext(PCNext),
        .PC(PC_F)
    );

    PC_Plus_4 pcplus4_inst (
        .PC(PC_F),
        .PCPlus4(PCPlus4_F)
    );

    // wire [31:0] PCNext;
    // if (!StallF)begin
    //     assign PCNext = PCSrcE ? PCTarget_E : PCPlus4_F;
    // end

    wire [31:0] PCNext;
    assign PCNext = PCSrcE ? PCTarget_E : PCPlus4_F;

    // IF/ID pipeline register
    wire [31:0] PC_D, PCPlus4_D, Instr_D;
    IF_ID_Pipeline if_id (
        .clk(clk),
        .reset(reset),
        .StallD(StallD),
        .FlushD(FlushD),
        .PC_F(PC_F),
        .PCPlus4_F(PCPlus4_F),
        .Instr_F(Instr),
        .PC_D(PC_D),
        .PCPlus4_D(PCPlus4_D),
        .Instr_D(Instr_D)
    );

    // ------------------------------------------------------------------
    // ID stage
    // ------------------------------------------------------------------
    wire [4:0] Rs1D, Rs2D, RdD;
    wire [31:0] RD1D, RD2D;
    wire [31:0] ImmExt_D;
    wire [1:0]  ResultSrcD, ImmSrcD, ALUOpD;
    wire        MemWriteD, BranchD, ALUSrcD, RegWriteD, JumpD, MemReadD;
    wire [3:0]  ALUControlD;

    // Register file (uses RegWriteW from WB stage)
    wire [31:0] ResultW;    // FIXED: 32 bits

    Register_File regfile (
        .clk(clk),
        .WE3(RegWriteW),
        .RA1(Instr_D[19:15]),
        .RA2(Instr_D[24:20]),
        .WA3(RdW),
        .WD3(ResultW),
        .RD1(RD1D),
        .RD2(RD2D)
    );


    assign Rs1D = Instr_D[19:15];
    assign Rs2D = Instr_D[24:20];
    assign RdD  = Instr_D[11:7];

    Extend extend_inst (
        .Instr(Instr_D[31:7]),
        .ImmSrc(ImmSrcD),
        .ImmExt(ImmExt_D)
    );

    Main_Decoder main_decoder (
        .op(Instr_D[6:0]),
        .ResultSrc(ResultSrcD),
        .MemWrite(MemWriteD),
        .Branch(BranchD),
        .ALUSrc(ALUSrcD),
        .RegWrite(RegWriteD),
        .Jump(JumpD),
        .ImmSrc(ImmSrcD),
        .ALUop(ALUOpD),
        .MemRead(MemReadD)
    );

    ALU_Decoder alu_decoder (
        .opb5(Instr_D[5]),
        .funct3(Instr_D[14:12]),
        .funct7b5(Instr_D[30]),
        .ALUOp(ALUOpD),
        .ALUControl(ALUControlD)
    );

    // Hazard unit
    Hazard_Unit hazard (
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .RdE(RdE),
        .MemReadE(MemReadE),
        .PCSrcE(PCSrcE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );

    // ID/EX pipeline register
    wire [31:0] PC_E, PCPlus4_E, ImmExt_E, RD1_E, RD2_E;
    wire [4:0]  Rs1E, Rs2E, RdE;
    wire [1:0]  ResultSrcE;
    wire        MemWriteE, BranchE, ALUSrcE, RegWriteE, JumpE, MemReadE;
    wire [3:0]  ALUControlE;

    ID_EX_Pipeline id_ex (
        .clk(clk),
        .reset(reset),
        .FlushE(FlushE),
        .PC_D(PC_D),
        .PCPlus4_D(PCPlus4_D),
        .ImmExt_D(ImmExt_D),
        .RD1_D(RD1D),
        .RD2_D(RD2D),
        .Rs1_D(Rs1D),
        .Rs2_D(Rs2D),
        .Rd_D(RdD),
        .ResultSrc_D(ResultSrcD),
        .MemWrite_D(MemWriteD),
        .Branch_D(BranchD),
        .ALUSrc_D(ALUSrcD),
        .RegWrite_D(RegWriteD),
        .Jump_D(JumpD),
        .MemRead_D(MemReadD),
        .ALUControl_D(ALUControlD),
        .PC_E(PC_E),
        .PCPlus4_E(PCPlus4_E),
        .ImmExt_E(ImmExt_E),
        .RD1_E(RD1_E),
        .RD2_E(RD2_E),
        .Rs1_E(Rs1E),
        .Rs2_E(Rs2E),
        .Rd_E(RdE),
        .ResultSrc_E(ResultSrcE),
        .MemWrite_E(MemWriteE),
        .Branch_E(BranchE),
        .ALUSrc_E(ALUSrcE),
        .RegWrite_E(RegWriteE),
        .Jump_E(JumpE),
        .MemRead_E(MemReadE),
        .ALUControl_E(ALUControlE)
    );

    // ------------------------------------------------------------------
    // EX stage
    // ------------------------------------------------------------------
    wire [31:0] SrcAE, SrcBE;
    wire [31:0] ForwardedA, ForwardedB;
    wire [1:0]  ForwardAE, ForwardBE;
    wire [31:0] ALUResult_E;
    wire        ZeroE;
    wire        BranchTakenE;

    // Forwarding unit (uses RegWriteM and RegWriteW from later pipeline stages)
    wire [4:0]  RdM, RdW;
    wire        RegWriteM, RegWriteW;

    Forwarding_Unit forward (
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdM(RdM),
        .RdW(RdW),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE)
    );

    // Forwarding muxes
    assign ForwardedA = (ForwardAE == 2'b10) ? ALUResult_M :
                        (ForwardAE == 2'b01) ? ResultW : RD1_E;
    assign ForwardedB = (ForwardBE == 2'b10) ? ALUResult_M :
                        (ForwardBE == 2'b01) ? ResultW : RD2_E;

    // ALU input mux
    ALU_Mux alu_mux (
        .WD(ForwardedB),
        .ImmExt(ImmExt_E),
        .ALUSrc(ALUSrcE),
        .B(SrcBE)
    );

    assign SrcAE = ForwardedA;

    ALU alu (
        .A(SrcAE),
        .B(SrcBE),
        .ALUControl(ALUControlE),
        .Zero(ZeroE),
        .Result(ALUResult_E)
    );




    // Branch target
    assign PCTarget_E = PC_E + ImmExt_E;

    assign BranchTakenE = BranchE & ZeroE;   // beq only (extend for other conditions later)
    assign PCSrcE = BranchTakenE | JumpE;

    // EX/MEM pipeline register
    wire [31:0] ALUResult_M, WriteData_M, PCPlus4_M;
    wire [1:0]  ResultSrcM;
    wire        MemWriteM;

    EX_MEM_Pipeline ex_mem (
        .clk(clk),
        .reset(reset),
        .ALUResult_E(ALUResult_E),
        .WriteData_E(ForwardedB),
        .PCPlus4_E(PCPlus4_E),
        .Rd_E(RdE),
        .ResultSrc_E(ResultSrcE),
        .MemWrite_E(MemWriteE),
        .RegWrite_E(RegWriteE),
        .ALUResult_M(ALUResult_M),
        .WriteData_M(WriteData_M),
        .PCPlus4_M(PCPlus4_M),
        .Rd_M(RdM),
        .ResultSrc_M(ResultSrcM),
        .MemWrite_M(MemWriteM),
        .RegWrite_M(RegWriteM)
    );

    assign ALUResult = ALUResult_M;
    assign WriteData = WriteData_M;
    assign MemWrite  = MemWriteM;

    // ------------------------------------------------------------------
    // MEM stage
    // ------------------------------------------------------------------
    wire [31:0] ReadData_M = ReadData;

    // MEM/WB pipeline register
    wire [31:0] ALUResult_W, ReadData_W, PCPlus4_W;
    wire [1:0]  ResultSrcW;

    MEM_WB_Pipeline mem_wb (
        .clk(clk),
        .reset(reset),
        .ALUResult_M(ALUResult_M),
        .ReadData_M(ReadData_M),
        .PCPlus4_M(PCPlus4_M),
        .Rd_M(RdM),
        .ResultSrc_M(ResultSrcM),
        .RegWrite_M(RegWriteM),
        .ALUResult_W(ALUResult_W),
        .ReadData_W(ReadData_W),
        .PCPlus4_W(PCPlus4_W),
        .Rd_W(RdW),
        .ResultSrc_W(ResultSrcW),
        .RegWrite_W(RegWriteW)
    );

    // Result mux (WB)
    Result_Mux result_mux (
        .ALUResult(ALUResult_W),
        .ReadData(ReadData_W),
        .PC_Plus_4(PCPlus4_W),
        .ResultSrc(ResultSrcW),
        .Result(ResultW)          // connects to the 32-bit wire
    );

    // FIXED: Connect the output PC to the actual PC signal
    assign PC = PC_F;

endmodule