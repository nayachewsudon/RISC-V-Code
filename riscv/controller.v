module controller_stageone(
    input [6:0] op, 
    output reg sel_result,
    output reg dmem_we,
    output reg sel_alu_src_b,
    output reg [1:0] sel_ext, //should change when extended to b, j, u 
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
        sel_ext = 2'b11; //should fall under default
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
    endcase
end

endmodule; 

module controller_stagetwo(
    input [14:12] funct3, 
    input [30] funct7,
    input [1:0] alu_op, 
    output reg [3:0] alu_control
); 

always @ (*) begin
    
end

endmodule;