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
    2'b10: begin //rtype and itype
        case (funct3)
        3'b000: begin
            case (funct7)
            1'b0: begin //add
                alu_control = 4'b0000;
            end
            1'b1: begin //sub
                alu_control = 4'b1000; 
            end
            default: alu_control = 4'bxxxx; 
            endcase
        end
        3'b001: begin //sll
            alu_control = 4'b0001;
        end
        3'b010: begin //slt
            alu_control = 4'b0010;
        end
        3'b011: begin //sltu
            alu_control = 4'b0011;
        end
        3'b100: begin //xor
            alu_control = 4'b0100;
        end
        3'b101: begin //slr
            case (funct7)
            1'b0: begin
                alu_control = 4'b0101;
            end
            1'b1: begin //sra
                alu_control = 4'b1101;
            end
            default: alu_control = 4'bxxxx;
            endcase 
        end
        3'b110: begin //or
            alu_control = 4'b0110;
        end
        3'b111: begin //and
            alu_control = 4'b0111;
        end
        default: alu_control = 4'bxxxx;
        endcase
    end
    2'b01: begin //beq for alu control subtraction
        alu_control = 4'b1000;
    end
    
    default: alu_control = 4'bxxxx;
    endcase
end

endmodule