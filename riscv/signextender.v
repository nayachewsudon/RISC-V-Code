module signextender (
    input [31:7] A, 
    input [2:0] sel_ext,
    output reg[31:0] out
);

always @(*) begin
    case (sel_ext) //CHANGE - deleted 3'b010
    3'b000: //lw, I-type
        out = {{20{A[31]}}, A[31:20]};
    3'b001: //sw
        out = {{20{A[31]}}, A[31:25], A[11:7]};
    3'b011: // B-type (beq)
        out = {{20{A[31]}}, A[7], A[30:25], A[11:8], 1'b0};
    3'b100: // J-type (jal)
        out = {{12{A[31]}}, A[19:12], A[20], A[30:21], 1'b0};
    3'b101: // U-type (lui)
        out = {A[31:12], 12'b0};
    default: out = 32'b0;
    endcase
end

endmodule