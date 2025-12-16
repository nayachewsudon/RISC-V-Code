module signextender (
    input [24:0] A, 
    input [2:0] sel_ext,
    output reg[31:0] out
);

always @(*) begin
    case (sel_ext) //CHANGE - deleted 3'b010
    3'b000: //lw, I-type
        out = {{20{A[24]}}, A[24:13]};
    3'b001: //sw
        out = {{20{A[24]}}, A[24:18], A[4:0]};
    3'b011: // B-type (beq)
        out = {{19{A[24]}}, A[24], A[0], A[23:18], A[4:1], 1'b0};
    3'b100: // J-type (jal)
        out = {{11{A[24]}}, A[24], A[12:5], A[13], A[23:14], 1'b0};
    3'b101: // U-type (lui)
        out = {A[24:5], 12'b0};
    default: out = 32'b0; 
    endcase
end

endmodule