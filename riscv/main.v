`include "components.v"
`include "controller.v"
`include "signextender.v"
`include "alu.v"

//fungsi: gabungin bagian2 risc-v dalam 1 module

module riscv(
    input clk, 
    input reset
);

//--Adder--
wire [31:0] adder_output;

adder adder (
    .pc(instruction_output),
    .pc_plus_4(adder_output)
);

//--PC + imm adder--
wire [31:0] sum; 
adder_general adder_general(
    .a(instruction_output),
    .b(se_out),
    .sum(sum)
);

//--Branch/Jump Logic--             
wire sel_pc;               
assign sel_pc = (branch & zero_flag) | sel_jump;

//--Mux for that logic--
wire [31:0] mux_logic;
multiplexer multiplexer_3(
    .in_a(sum),
    .in_b(adder_output),
    .sel(sel_pc),
    .out_m(mux_logic)
);

//--PC--
wire [31:0] instruction_output;

programcounter programcounter (
    .clk_pc(clk),
    .reset_pc(reset),
    .in_pc(mux_logic),
    .out_pc(instruction_output)
);

//--Instruction Memory--
wire [31:0] rd_im_output;

instruction_memory instruction_memory (
    .a_im(instruction_output),
    .rd_im(rd_im_output)
);

//--Register File--
wire [31:0] rd1_rf;
wire [31:0] rd2_rf;

register_file register_file (
    .clk_r(clk),
    .reset_r(reset),
    .a1(rd_im_output[19:15]),
    .a2(rd_im_output[24:20]),
    .a3(rd_im_output[11:7]),
    .wd3(mux_two),
    .rd1(rd1_rf),
    .rd2(rd2_rf),
    .we3(rf_we) 
);

//--Mux 1--
wire  [31:0] mux_one;

multiplexer multiplexer1 (
    .in_a(se_out),
    .in_b(rd2_rf), 
    .sel(sel_alu_src_b),
    .out_m(mux_one)
);

//--Data Memory--
wire [31:0] rd_dm;

data_memory data_memory(
    .a_dm(alu_output),
    .clk_dm(clk),
    .reset_dm(reset),
    .wd_dm(rd2_rf),
    .we(dmem_we),
    .rd_dm(rd_dm)
);

//--Mux 2--
wire [31:0] mux_two;
mux_3to1 multiplexer2(
    .in_a(alu_output),
    .in_b(rd_dm),
    .in_c(adder_output),
    .sel_res(sel_result),
    .out_m(mux_two)
);

//--Controller (bagian pertama)--
wire [1:0] sel_result; 
wire dmem_we; 
wire sel_alu_src_b;
wire [2:0] sel_ext;    
wire rf_we;
wire branch;             
wire sel_jump;          
wire [1:0] alu_op;

controller_stageone controller_stageone(
    .op(rd_im_output[6:0]),
    .sel_result(sel_result),
    .dmem_we(dmem_we),
    .sel_alu_src_b(sel_alu_src_b),
    .sel_ext(sel_ext),
    .rf_we(rf_we),
    .branch(branch),        
    .sel_jump(sel_jump),  
    .alu_op(alu_op)
);

//--Controller (bagian kedua)--
wire [3:0] alu_control;

controller_stagetwo controller_stagetwo(
    .funct3(rd_im_output[14:12]),
    .funct7(rd_im_output[30]),
    .alu_op(alu_op),
    .alu_control(alu_control)
);

//--Sign Extender --
wire [31:0] se_out;

signextender signextender(
    .A(rd_im_output[31:7]),
    .sel_ext(sel_ext),
    .out(se_out)
);

//--ALU--
wire [31:0] alu_output;
wire zero_flag; 
alu alu(
    .a(rd1_rf),
    .b(mux_one),
    .alu_controller(alu_control),
    .rd(alu_output),
    .zero_flag(zero_flag)
);

endmodule
