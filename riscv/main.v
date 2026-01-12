`include "components.v"
`include "controller.v"
`include "signextender.v"
`include "alu.v"
`include "pipeline_registers.v"
`include "hazard_unit.v"

module rv_pl(
    input clk, 
    input rst_n
);

//-------------------------------------
//--STAGE ONE: INSTRUCTION FETCH (IF)--
//-------------------------------------

//--PC--
wire [31:0] F_PC;

programcounter PROGRAMCOUNTER (
    .clk(clk),
    .reset(rst_n),
    .input_pc(branch_jump_mux_result),
    .F_stall(F_stall), //Addition to handle load hazards
    .updated_pc(F_PC)
);

//--Adder adding PC + 4--
wire [31:0] F_PC_P4; 

adder ADDER (
    .pc(F_PC),
    .pc_plus_4(F_PC_P4)
);

//--Instruction Memory--
wire [31:0] F_instr;

instruction_memory IMEM (
    .a_im(F_PC),
    .rd_im(F_instr)
);

//--Mux for branch/jump--
wire [31:0] branch_jump_mux_result;
multiplexer BRANCH_JUMP_MULTIPLEXER(
    .in_a(E_target_PC), //sel_pc = 1, jump to target address
    .in_b(F_PC_P4), //sel_pc = 0
    .sel(sel_pc),
    .out_m(branch_jump_mux_result)
);

//--PLR1 Register --
wire [31:0] D_instr;
wire [31:0] D_PC;
wire [31:0] D_PC_P4;

plr1 PLR1(
    .clk(clk),
    .rst_n(rst_n),
    .F_instr(F_instr),
    .F_PC(F_PC),
    .F_PC_P4(F_PC_P4),
    .D_flush(D_flush), //part of control hazard mechanism
    .D_stall(D_stall), //part of stalling mechanism
    .D_instr(D_instr),
    .D_PC(D_PC),
    .D_PC_P4(D_PC_P4)
);

//-------------------------------------
//--STAGE TWO: INSTRUCTION DECODE (ID)--
//-------------------------------------

//--Register File--
wire [31:0] D_rf_rd1;
wire [31:0] D_rf_rd2;

register_file RF (
    .clk_r(clk),
    .reset_n(rst_n),
    .a1(D_instr[19:15]),
    .a2(D_instr[24:20]),
    .a3(W_rf_a3), 
    .wd3(W_result),
    .rd1(D_rf_rd1),
    .rd2(D_rf_rd2),
    .we3(W_we_rf)
);

//--Stage one controller--
wire [1:0] D_sel_result; 
wire D_we_dm; 
wire D_sel_alu_src_b;
wire [2:0] D_sel_ext;    
wire D_we_rf;
wire D_branch;             
wire D_jump;          
wire [1:0] alu_op;
wire D_lui; //For LUI

controller_stageone STAGEONE_CONTROLLER(
    .op(D_instr[6:0]),
    .sel_result(D_sel_result),
    .dmem_we(D_we_dm),
    .sel_alu_src_b(D_sel_alu_src_b),
    .sel_ext(D_sel_ext),
    .rf_we(D_we_rf),
    .branch(D_branch),        
    .sel_jump(D_jump),
    .alu_op(alu_op),
    .lui(D_lui)
);

//--Controller stage 2--
wire [3:0] D_alu_control;

controller_stagetwo STAGETWO_CONTROLLER(
    .funct3(D_instr[14:12]),
    .funct7(D_instr[30]),
    .alu_op(alu_op),
    .alu_control(D_alu_control)
);

//--Sign Extender --
wire [31:0] D_ext;

signextender SIGNEXTENDER(
    .A(D_instr[31:7]),
    .sel_ext(D_sel_ext),
    .out(D_ext)
);

//--PLR2 Reg--
    wire E_jump;
    wire E_branch;
    wire [1:0] E_sel_result;
    wire E_we_dm;
    wire [3:0] E_alu_control; 
    wire E_sel_alu_src_b;
    wire E_lui; //For LUI 
    wire E_we_rf;
    wire [31:0] E_rf_rd1; 
    wire [31:0] E_rf_rd2; 
    wire [4:0] E_rf_a3; 
    wire [31:0] E_ext; 
    wire [31:0] E_PC; 
    wire [31:0] E_PC_P4;
    wire [4:0] E_rs1; //Forwarding addition
    wire [4:0] E_rs2; //Forwarding addition

    wire [4:0] D_rs1; 
    assign D_rs1 = D_instr[19:15];
    wire [4:0] D_rs2;
    assign D_rs2 = D_instr[24:20];

plr2 PLR2(
    .clk(clk),
    .rst_n(rst_n),

    //DECODE
    .D_jump(D_jump),
    .D_branch(D_branch),
    .D_sel_result(D_sel_result),
    .D_we_dm(D_we_dm),
    .D_alu_control(D_alu_control),
    .D_sel_alu_src_b(D_sel_alu_src_b),
    .D_we_rf(D_we_rf),
    .D_rf_rd1(D_rf_rd1),
    .D_rf_rd2(D_rf_rd2),
    .D_rf_a3(D_instr[11:7]),
    .D_ext(D_ext),
    .D_PC(D_PC),
    .D_PC_P4(D_PC_P4),
    .D_lui(D_lui), //LUI Addition
    .D_rs1(D_rs1), //Forwarding addition
    .D_rs2(D_rs2), //Forwarding addition

    //EXECUTE
    .E_jump(E_jump),
    .E_branch(E_branch),
    .E_sel_result(E_sel_result),
    .E_we_dm(E_we_dm),
    .E_alu_control(E_alu_control),
    .E_sel_alu_src_b(E_sel_alu_src_b),
    .E_we_rf(E_we_rf),
    .E_rf_rd1(E_rf_rd1),
    .E_rf_rd2(E_rf_rd2),
    .E_rf_a3(E_rf_a3),
    .E_ext(E_ext),
    .E_PC(E_PC),
    .E_PC_P4(E_PC_P4),
    .E_lui(E_lui), //LUI Addition
    .E_rs1(E_rs1), //Forwarding addition
    .E_rs2(E_rs2), //Forwarding addition

    //Contrl hazard flushing
    .E_flush(E_flush)
);

//-------------------------------------
//--STAGE THREE: INSTRUCTION EXECUTION (EX)--
//-------------------------------------

//--Branch/Jump Logic--
wire sel_pc;               
assign sel_pc = (E_branch & E_zero) | E_jump;

//Forward mux A
wire [31:0] E_forward_result_a; 
mux_3to1 FORWARD_MUX_A (
    .in_a(E_rf_rd1), //00
    .in_b(W_result), //01
    .in_c(M_alu_o), //10
    .sel_res(E_forward_a),
    .out_m(E_forward_result_a)
);

//Forward mux B
wire [31:0] E_forward_result_b;
mux_3to1 FORWARD_MUX_B (
    .in_a(E_rf_rd2), 
    .in_b(W_result),
    .in_c(M_alu_o),
    .sel_res(E_forward_b),
    .out_m(E_forward_result_b)
);

//--PC + imm adder--
wire [31:0] E_target_PC; 
adder_general PC_IMM_ADDER(
    .a(E_ext),
    .b(E_PC),
    .sum(E_target_PC)
);

//--SrcB Mux--
wire  [31:0] srcB;

multiplexer SE_RD2_MUX (
    .in_a(E_ext), //src_b = 1
    .in_b(E_forward_result_b), //src_b = 0 -> from forward mux b
    .sel(E_sel_alu_src_b),
    .out_m(srcB)
);

//--ALU--
wire [31:0] E_alu_o;
wire E_zero; 
alu ALU(
    .a(E_forward_result_a),
    .b(srcB),
    .alu_controller(E_alu_control),
    .lui(E_lui),
    .rd(E_alu_o),
    .zero_flag(E_zero)
);

//--PLR3 Reg--
    wire [1:0] M_sel_result;
    wire M_we_dm;
    wire M_we_rf;
    wire [31:0] M_alu_o;
    wire [4:0] M_rf_a3;
    wire [31:0] M_PC_P4;
    wire [31:0] M_dm_wd;

    plr3 PLR3(
        .clk(clk),
        .rst_n(rst_n),
        .E_sel_result(E_sel_result),
        .E_we_dm(E_we_dm),
        .E_we_rf(E_we_rf),
        .E_alu_o(E_alu_o),
        .E_dm_wd(E_forward_result_b), //Check diagram again
        .E_rf_a3(E_rf_a3),
        .E_PC_P4(E_PC_P4),
        .M_sel_result(M_sel_result),
        .M_we_dm(M_we_dm),
        .M_we_rf(M_we_rf),
        .M_alu_o(M_alu_o),
        .M_dm_wd(M_dm_wd),
        .M_rf_a3(M_rf_a3),
        .M_PC_P4(M_PC_P4)
    );


//-------------------------------------
//--STAGE FOUR: MEMORY ACCESS (MA)--
//-------------------------------------

//--Data Memory--
wire [31:0] M_dm_rd;

data_memory DMEM(
    .a_dm(M_alu_o),
    .clk(clk),
    .wd_dm(M_dm_wd),
    .we(M_we_dm),
    .rd_dm(M_dm_rd)
);

//--PL4 Register--
wire [1:0] W_sel_result;
wire W_we_rf;
wire [31:0] W_alu_o;
wire [31:0] W_dm_rd;
wire [4:0] W_rf_a3; 
wire [31:0] W_PC_P4;

plr4 PLR4(
    .clk(clk),
    .rst_n(rst_n),
    .M_sel_result(M_sel_result),
    .M_we_rf(M_we_rf),
    .M_alu_o(M_alu_o),
    .M_dm_rd(M_dm_rd),
    .M_rf_a3(M_rf_a3),
    .M_PC_P4(M_PC_P4),
    .W_sel_result(W_sel_result),
    .W_we_rf(W_we_rf),
    .W_alu_o(W_alu_o),
    .W_dm_rd(W_dm_rd),
    .W_rf_a3(W_rf_a3),
    .W_PC_P4(W_PC_P4)
);

//-------------------------------------
//--STAGE FIVE: WRITEBACK (WB)--
//-------------------------------------

//--Mux 2 (Writeback multiplexer)--
wire [31:0] W_result;
mux_3to1 WRITEBACK_MULTIPLEXER(
    .in_a(W_alu_o), //00
    .in_b(W_dm_rd), //01
    .in_c(W_PC_P4), //10
    .sel_res(W_sel_result),
    .out_m(W_result)
);


//-------------------------------------
//--Hazard Unit--
//-------------------------------------
//Forwarding
wire [1:0] E_forward_a; //Control signal for 3to1 mux
wire [1:0] E_forward_b; //Contrl signal for 3to1 mux

//Stalling - load hazard
wire E_flush; 
wire D_stall; 
wire F_stall;  

//Control hazard
wire D_flush;

hazard_unit HAZARDUNIT(
    //Forwarding ports
    .E_rs1(E_rs1),
    .E_rs2(E_rs2),
    .M_we_rf(M_we_rf),
    .W_we_rf(W_we_rf),
    .W_rf_a3(W_rf_a3),
    .M_rf_a3(M_rf_a3),
    .E_forward_a(E_forward_a),
    .E_forward_b(E_forward_b),
    
    //Stalling
    .E_sel_result(E_sel_result),
    .E_rf_a3(E_rf_a3),
    .D_rs1(D_rs1),
    .D_rs2(D_rs2),
    .E_flush(E_flush),
    .D_stall(D_stall),
    .F_stall(F_stall),

    //Control hazard handling
    .sel_pc(sel_pc),
    .D_flush(D_flush)

);

endmodule