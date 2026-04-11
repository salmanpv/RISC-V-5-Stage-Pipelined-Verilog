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