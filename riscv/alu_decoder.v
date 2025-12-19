module alu_decoder(
    input [2:0] funct3, 
    input funct7, //ambil bit ke-6 di bagian funct7
    input [1:0] alu_op, 
    output reg [3:0] alu_control
); 

always @ (*) begin
    case (alu_op)
    2'b00: begin //lw, sw, jal and lui
        alu_control = {3'b000, 1'b0};
    end 
    2'b01: begin //R-type
        case (funct3)
        3'b000: begin
            if (funct7 == 1'b1)
                alu_control = 4'b1000; //sub
            else
                alu_control = 4'b0000; // add
        end
        3'b001: alu_control = 4'b0001; //sll
        3'b010: alu_control = 4'b0010; //slt
        3'b011: alu_control = 4'b0011; //sltu
        3'b100: alu_control = 4'b0100; //xor
        3'b101: begin
            if (funct7 == 1'b1)
                alu_control = 4'b1101; // sra
            else
                alu_control = 4'b0101; // srl
        end
        3'b110: alu_control = 4'b0110; //or
        3'b111: alu_control = 4'b0111; //and
        default: alu_control = 4'bxxxx;
        endcase
    end
    
    2'b10: begin //I-type
        case (funct3)
        3'b000: alu_control = 4'b0000; // addi
        3'b001: alu_control = 4'b0001; // slli
        3'b010: alu_control = 4'b0010; // slti
        3'b011: alu_control = 4'b0011; // sltiu
        3'b100: alu_control = 4'b0100; // xori
        3'b101: begin
            if (funct7 == 1'b1)
                alu_control = 4'b1101; // srai
            else
                alu_control = 4'b0101; // slri
        end
        3'b110: alu_control = 4'b0110; // ori
        3'b111: alu_control = 4'b0111; // andi
        default: alu_control = 4'bxxxx;
        endcase
    end
    2'b01: begin
        alu_control = 4'b1000;
    end
    
    default: alu_control = 4'bxxxx;
    endcase
end

endmodule