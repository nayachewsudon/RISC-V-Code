module signextender (
    input [24:0] A, 
    input [1:0] sel_ext,
    output reg[31:0] out
);

always @(*) begin //TODO: Tambah B, J, L stlh testbench
    case (sel_ext) 
    2'b00, 2'b10: //lw, I-type
        out = {{20{A[24]}}, A[24:13]};
    2'b01: //sw
        out = {{20{A[24]}}, A[24:18], A[4:0]};
    default: out = 32'b0; 
    endcase
end

endmodule