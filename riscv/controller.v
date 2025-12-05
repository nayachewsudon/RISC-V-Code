module controller_stageone(
    input [6:0] op, 
    output reg sel_result,
    output reg dmem_we,
    output reg sel_alu_src_b,
    output reg [1:0] sel_ext, //TODO: bit size diganti pas tambah B, J, U, dll
    output reg rf_we, 
    output reg [1:0] alu_op
); 

always @ (*) begin
    case (op)
    7'b0000011: begin
        rf_we = 1'b1;
        sel_ext = 2'b00;
        sel_alu_src_b = 1'b1;
        dmem_we = 1'b0;
        sel_result = 1'b0;
        alu_op = 2'b00;
    end
    7'b0100011: begin
        rf_we = 1'b0;
        sel_ext = 2'b01;
        sel_alu_src_b = 1'b1;
        dmem_we = 1'b1;
        sel_result = 1'b1;
        alu_op = 2'b00;
    end
    7'b0110011: begin
        rf_we = 1'b1;
        sel_ext = 2'b11; //TODO: termasuk dalam default
        sel_alu_src_b = 1'b0;
        dmem_we = 1'b0;
        sel_result = 1'b1;
        alu_op = 2'b01;
    end
    7'b0010011: begin
        rf_we = 1'b1;
        sel_ext = 2'b10;
        sel_alu_src_b = 1'b1;
        dmem_we = 1'b0;
        sel_result = 1'b1;
        alu_op = 2'b10;
    end
    default: begin
        sel_result = 0;
        dmem_we = 0;
        sel_alu_src_b = 0;
        sel_ext = 2'b00;
        rf_we = 0;
        alu_op = 2'b00; 
    end
    endcase
end

endmodule

module controller_stagetwo(
    input [2:0] funct3, 
    input funct7, //ambil bit ke-6 di bagian funct7
    input [1:0] alu_op, 
    output reg [3:0] alu_control
); 

always @ (*) begin
    case (alu_op)
    2'b00: begin
        alu_control = {3'b000, 1'b0};
    end 
    2'b01, 2'b10: begin
        case (funct3)
        3'b000: begin
            case (funct7)
            1'b0: begin
                alu_control = 4'b0000;
            end
            1'b1: begin
                alu_control = 4'b1000; 
            end
            default: alu_control = 4'b1111; //TODO: check if this is okay
            endcase
        end
        3'b001: begin
            alu_control = 4'b0001;
        end
        3'b010: begin
            alu_control = 4'b0010;
        end
        3'b011: begin
            alu_control = 4'b0011;
        end
        3'b100: begin
            alu_control = 4'b0100;
        end
        3'b101: begin
            case (funct7)
            1'b0: begin
                alu_control = 4'b0101;
            end
            1'b1: begin
                alu_control = 4'b1101;
            end
            default: alu_control = 4'b1111; //TODO
            endcase 
        end
        3'b110: begin
            alu_control = 4'b0110;
        end
        3'b111: begin
            alu_control = 4'b0111;
        end
        default: alu_control = 4'b1111; //TODO
        endcase
    end
    default: alu_control = 4'b1111; //TODO
    endcase
end

endmodule