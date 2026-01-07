//--Separates IF and ID--
module plr1(
    input clk, 
    input [31:0] F_instr, 
    input [31:0] F_PC, 
    input [31:0] F_PC_P4, 
    output reg [31:0] D_instr, 
    output reg [31:0] D_PC, 
    output reg [31:0] D_PC_P4
); 

always @ (posedge clk) begin
    D_instr <= F_instr; 
    D_PC <= F_PC; 
    D_PC_P4 <= F_PC_P4;
end
endmodule

//-- Separates ID and EX --
module plr2(
    input clk, 
    input D_jump, 
    input D_branch, 
    input [1:0] D_sel_result, 
    input D_we_dm, 
    input [3:0] D_alu_control, 
    input D_sel_alu_src_b, 
    input D_we_rf,
    input [31:0] D_rf_rd1, 
    input [31:0] D_rf_rd2, 
    input [11:7] D_rf_a3, 
    input [31:0] D_ext, 
    input [31:0] D_PC, //from PLR1
    input [31:0] D_PC_P4,
    input D_sel_alu_src_a,
    output reg E_jump, 
    output reg E_branch, 
    output reg [1:0] E_sel_result, 
    output reg E_we_dm, 
    output reg [3:0] E_alu_control, 
    output reg E_sel_alu_src_b, 
    output reg E_we_rf, 
    output reg [31:0] E_rf_rd1, 
    output reg [31:0] E_rf_rd2, 
    output reg [11:7] E_rf_a3, 
    output reg [31:0] E_ext, 
    output reg [31:0] E_PC, 
    output reg [31:0] E_PC_P4,
    output reg E_sel_alu_src_a
); 

always @ (posedge clk) begin
    E_jump <= D_jump;
    E_branch <= D_branch;
    E_sel_result <= D_sel_result;
    E_we_dm <= D_we_dm; 
    E_alu_control <= D_alu_control;
    E_sel_alu_src_b <= D_sel_alu_src_b; 
    E_we_rf <= D_we_rf;
    E_rf_rd1 <= D_rf_rd1;
    E_rf_rd2 <= D_rf_rd2; 
    E_rf_a3 <= D_rf_a3; 
    E_ext <= D_ext; 
    E_PC <= D_PC; 
    E_PC_P4 <= D_PC_P4;
    E_sel_alu_src_a <= D_sel_alu_src_a;
end

endmodule

module plr3(
    input clk, 
    input [1:0] E_sel_result,
    input E_we_dm,
    input E_we_rf, 
    input [31:0] E_alu_o, 
    input [31:0] E_dm_wd, 
    input [11:7] E_rf_a3,
    input [31:0] E_PC_P4,
    output reg [1:0] M_sel_result, 
    output reg M_we_dm, 
    output reg M_we_rf, 
    output reg [31:0] M_alu_o,
    output reg [31:0] M_dm_wd,
    output reg [11:7] M_rf_a3,
    output reg [31:0] M_PC_P4
); 

always @ (posedge clk) begin
    M_sel_result <= E_sel_result;    
    M_we_dm <= E_we_dm;
    M_we_rf <= E_we_rf; 
    M_alu_o <= E_alu_o; 
    M_dm_wd <= E_dm_wd; 
    M_rf_a3 <= E_rf_a3; 
    M_PC_P4 <= E_PC_P4;
end
endmodule 

module plr4(
    input clk, 
    input [1:0] M_sel_result, 
    input M_we_dm, 
    input M_we_rf, 
    input [31:0] M_alu_o, 
    input [31:0] M_dm_rd, //connected to data memory 
    input [11:7] M_rf_a3, 
    input [31:0] M_PC_P4,
    output reg [1:0] W_sel_result,
    output reg W_we_rf, 
    output reg [31:0] W_alu_o, 
    output reg [31:0] W_dm_rd,
    output reg [11:7] W_rf_a3, 
    output reg [31:0] W_PC_P4
); 

always @ (posedge clk) begin
    W_sel_result <= M_sel_result; 
    W_we_rf <= M_we_rf; 
    W_alu_o <= M_alu_o; 
    W_dm_rd <= M_dm_rd; 
    W_rf_a3 <= M_rf_a3; 
    W_PC_P4 <= M_PC_P4; 
end
endmodule