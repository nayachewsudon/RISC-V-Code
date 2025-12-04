module signextender (
    input [31:7] A, 
    input [1:0] sel_ext,
    output reg[31:0] out
); //extends immediate value from different instruction types to 32 bit

always @(*) begin //TODO: Add B, J, L AFTER testbench
    case (sel) 
    7'b0110011: 
        out = 32'h00000000;
    7'b0010011, 7'b0000011, 7'b1100111, 7'b1110011: //I-type
        out = {20{A[31]}, A[31:20]};
    7'b0100011: //S-type
        out = {20{A[31]}, A[31:25], A[11:7]};
        //default ? 
    endcase
end

endmodule;