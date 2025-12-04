module alu(
    input [31:0] a, b,
    input [3:0] alu_controller, 
    output reg [31:0] rd
);

//Writing only for R-Type first
always @(*) begin
    case(alu_controller)
        4'b0000: //add
        begin 
            rd = a + b;
        end
        4'b1000: //sub
        begin 
            rd = a - b;
        end 
        4'b0001: //sll
        begin 
            rd = a << b[4:0];
        end
        4'b0010: //slt
        begin 
            rd = {31'b0, ($signed(a) < $signed(b))};    
        end
        4'b0011: //sltu 
        begin 
            rd = {31'b0, a < b};
        end
        4'b0100: //xor
        begin
            rd = a ^ b;
        end 
        4'b0101: //srl
        begin 
            rd = a >> b[4:0];
        end
        4'b1101: //sra
        begin 
            rd = a >>> b[4:0];
        end
        4'b0110: //or
        begin 
            rd = a | b;
        end 
        4'b0111: //and
        begin 
            rd = a & b;
        end
        default: rd = 32'b0;
    endcase
end

endmodule