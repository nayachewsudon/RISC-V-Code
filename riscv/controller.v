module controller_stageone(
    input [6:0] op, 
    output reg [1:0] sel_result,
    output reg dmem_we,
    output reg sel_alu_src_b,
    output reg [2:0] sel_ext, 
    output reg rf_we, 
    output reg branch, 
    output reg sel_jump,
    output reg [1:0] alu_op
); 

always @ (*) begin
    case (op)
    7'b0000011: begin //lw
        rf_we = 1'b1;
        sel_ext = 3'b000;
        sel_alu_src_b = 1'b1;
        dmem_we = 1'b0;
        sel_result = 2'b01;
        branch = 0;
        sel_jump = 0;
        alu_op = 2'b00;
    end
    7'b0100011: begin //sw
        rf_we = 1'b0;
        sel_ext = 3'b001;
        sel_alu_src_b = 1'b1;
        dmem_we = 1'b1;
        sel_result = 2'b00;
        branch = 0;
        sel_jump = 0;
        alu_op = 2'b00;
    end
    7'b0110011: begin //R-Type
        rf_we = 1'b1;
        sel_ext = 3'b111; 
        sel_alu_src_b = 1'b0;
        dmem_we = 1'b0;
        sel_result = 2'b00;
        branch = 0;
        sel_jump = 0;
        alu_op = 2'b01;
    end
    7'b0010011: begin
        rf_we = 1'b1;
        sel_ext = 3'b010;
        sel_alu_src_b = 1'b1;
        dmem_we = 1'b0;
        sel_result = 2'b00;
        branch = 0;
        sel_jump = 0;
        alu_op = 2'b10;
    end
    7'b1100011: begin //beq
        rf_we = 1'b0;
        sel_ext = 3'b011;
        sel_alu_src_b = 1'b0;
        dmem_we = 1'b0;
        sel_result = 2'b00;
        branch = 1;
        sel_jump = 0;
        alu_op = 2'b11;
    end
    7'b0110111: begin //lui
        rf_we = 1'b1;
        sel_ext = 3'b101; 
        sel_alu_src_b = 1'b1;
        dmem_we = 1'b0;
        sel_result = 2'b00;  
        branch = 0;
        sel_jump = 0;         
        alu_op = 2'b00; 
    end
    7'b1101111: begin //jal
        rf_we = 1'b1;
        sel_ext = 3'b100;  
        sel_alu_src_b = 1'b1;
        dmem_we = 1'b0;
        sel_result = 2'b10;    
        branch = 0;
        sel_jump = 1;       
        alu_op = 2'b00;
    end
    default: begin
        rf_we = 1'b0;
        sel_ext = 3'b111;
        sel_alu_src_b = 1'b0;
        dmem_we = 1'b0;
        sel_result = 2'b00;
        branch = 0;
        sel_jump = 0;
        alu_op = 2'b00; 
    end
    endcase
end

endmodule

module controller_stagetwo(
    input [2:0] funct3, 
    input funct7, 
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
    2'b11: begin
        alu_control = 4'b1000;
    end
    
    default: alu_control = 4'bxxxx;
    endcase
end


endmodule