`include "components.v"
`include "controller.v"
`include "signextender.v"
`include "alu.v"

module riscv(
    input clk, 
    input rst_n
);

//--Adder adding PC + 4--
wire [31:0] pc_p4; 

adder ADDER (
    .pc(updated_pc),
    .pc_plus_4(pc_p4)
);

//--PC + imm adder--
wire [31:0] pc_p_imm; 
adder_general PC_IMM_ADDER(
    .a(updated_pc),
    .b(se_out),
    .sum(pc_p_imm)
);

//--Branch/Jump Logic--             
wire sel_pc;               
assign sel_pc = (branch & zero_flag) | sel_jump;

//--Mux for that logic--
wire [31:0] mux_logic;
multiplexer BRANCH_JUMP_MULTIPLEXER(
    .in_a(pc_p_imm), //from pc + imm adder
    .in_b(pc_p4), //from adder of pc + 4
    .sel(sel_pc),
    .out_m(mux_logic)
);

//--PC--
wire [31:0] updated_pc;

programcounter PROGRAMCOUNTER (
    .clk(clk),
    .reset(rst_n),
    .input_pc(mux_logic),
    .updated_pc(updated_pc)
);

//--Instruction Memory--
wire [31:0] rd_im_output;

instruction_memory IMEM (
    .a_im(updated_pc),
    .rd_im(rd_im_output)
);

//--Register File--
wire [31:0] rf_rd1;
wire [31:0] rf_rd2;

register_file RF (
    .clk_r(clk),
    .reset_r(rst_n),
    .a1(rd_im_output[19:15]),
    .a2(rd_im_output[24:20]),
    .a3(rd_im_output[11:7]),
    .wd3(mux_two),
    .rd1(rf_rd1),
    .rd2(rf_rd2),
    .we3(rf_we) 
);

//--Mux 1--
wire  [31:0] srcB;

multiplexer SE_RD2_MUX (
    .in_a(se_out),
    .in_b(rf_rd2), 
    .sel(sel_alu_src_b),
    .out_m(srcB)
);

//--Data Memory--
wire [31:0] rd_dm;

data_memory DMEM(
    .a_dm(alu_output),
    .clk(clk),
    .reset(rst_n),
    .wd_dm(rf_rd2),
    .we(dmem_we),
    .rd_dm(rd_dm)
);

//--Mux 2 (Writeback multiplexer)--
wire [31:0] mux_two;
mux_3to1 WRITEBACK_MULTIPLEXER(
    .in_a(alu_output),
    .in_b(rd_dm),
    .in_c(pc_p4),
    .sel_res(sel_result),
    .out_m(mux_two)
);

//--Stage one controller--
wire [1:0] sel_result; 
wire dmem_we; 
wire sel_alu_src_b;
wire [2:0] sel_ext;    
wire rf_we;
wire branch;             
wire sel_jump;          
wire [1:0] alu_op;
wire sel_alu_src_a;

controller_stageone STAGEONE_CONTROLLER(
    .op(rd_im_output[6:0]),
    .sel_result(sel_result),
    .dmem_we(dmem_we),
    .sel_alu_src_b(sel_alu_src_b),
    .sel_ext(sel_ext),
    .rf_we(rf_we),
    .branch(branch),        
    .sel_jump(sel_jump),  
    .alu_op(alu_op),
    .sel_alu_src_a(sel_alu_src_a)
);

//--Controller stage 2--
wire [3:0] alu_control;

controller_stagetwo STAGETWO_CONTROLLER(
    .funct3(rd_im_output[14:12]),
    .funct7(rd_im_output[30]),
    .alu_op(alu_op),
    .alu_control(alu_control)
);

//--Sign Extender --
wire [31:0] se_out;

signextender SIGNEXTENDER(
    .A(rd_im_output[31:7]),
    .sel_ext(sel_ext),
    .out(se_out)
);

//--ALU--
wire [31:0] alu_output;
wire zero_flag; 
alu ALU(
    .a(srcA),
    .b(srcB),
    .alu_controller(alu_control),
    .rd(alu_output),
    .zero_flag(zero_flag)
);

//--SrcA Mux--
wire [31:0] input_zero = 32'b0;
wire [31:0] srcA; 

multiplexer ALU_SRCA_MUX(
    .in_a(input_zero),
    .in_b(rf_rd1),
    .sel(sel_alu_src_a),
    .out_m(srcA)
);

endmodule