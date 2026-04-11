(* keep_hierarchy = "yes" *)
module Instruction_Memory(
    input [31:0] A,
    output [31:0] RD
);

(* ram_style = "distributed", keep = "true" *)
reg [31:0] I_MEM_BLOCK[0:63];

initial begin
    $readmemh("instructions.mem", I_MEM_BLOCK);
end

assign RD = I_MEM_BLOCK[A[31:2]];

endmodule