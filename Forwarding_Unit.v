module Forwarding_Unit (
    input  wire [4:0] Rs1E, Rs2E,
    input  wire [4:0] RdM, RdW,
    input  wire       RegWriteM, RegWriteW,
    output reg  [1:0] ForwardAE,
    output reg  [1:0] ForwardBE
);

    always @(*) begin
        // Default: no forwarding
        ForwardAE = 2'b00;
        ForwardBE = 2'b00;

        // Forward from MEM
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs1E))
            ForwardAE = 2'b10;
        if (RegWriteM && (RdM != 5'b0) && (RdM == Rs2E))
            ForwardBE = 2'b10;

        // Forward from WB (if not already forwarded from MEM)
        if (RegWriteW && (RdW != 5'b0) && (RdW == Rs1E) && !(RegWriteM && (RdM == Rs1E)))
            ForwardAE = 2'b01;
        if (RegWriteW && (RdW != 5'b0) && (RdW == Rs2E) && !(RegWriteM && (RdM == Rs2E)))
            ForwardBE = 2'b01;
    end

endmodule