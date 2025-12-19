module alu(
    input [31:0] a, b,
    input [3:0] alu_controller, 
    output reg [31:0] alu_result,
    output zero
);

always @(*) begin
    case(alu_controller)
        4'b0000: //add
        begin 
            alu_result = a + b;
        end
        4'b1000: //sub
        begin 
            alu_result = a - b;
        end 
        4'b0001: //sll
        begin 
            alu_result = a << b[4:0];
        end
        4'b0010: //slt
        begin 
            alu_result = {31'b0, ($signed(a) < $signed(b))};    
        end
        4'b0011: //sltu 
        begin 
            alu_result = (a < b) ? 32'b1 : 32'b0;
        end
        4'b0100: //xor
        begin
            alu_result = a ^ b;
        end 
        4'b0101: //srl
        begin 
            alu_result = a >> b[4:0];
        end
        4'b1101: //sra
        begin 
            alu_result = $signed(a) >>> b[4:0]; 
        end
        4'b0110: //or
        begin 
            alu_result = a | b;
        end 
        4'b0111: //and
        begin 
            alu_result = a & b;
        end
        default: alu_result = 32'bx;
    endcase
end

//Noww we raise the zero flag if a == b
assign zero = (alu_result == 32'b0);

endmodule