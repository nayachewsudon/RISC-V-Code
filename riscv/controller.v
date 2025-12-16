`include "alu_decoder.v"
`include "fsm.v"
`include "instruction_decoder.v"

module controller(
    input clk, 
    input reset_n,
    input zero, //TODO: NOT IN THE CURRENT DIAGRAM
    input [6:0] op, 
    input [2:0] funct3,
    input funct7,
    output we_pc
    //--FSM OUTPUTS--
    output [1:0] sel_result,
    output [1:0] sel_alu_src_b,
    output [1:0] sel_alu_src_a,
    output [1:0] sel_mem_addr,
    output we_mem,
    output we_ir,
    output we_rf,
    //--ALU DECODER OUTPUT--
    output [3:0] alu_control,
    //--INSTRUCTION DECODER OUTPUT --
    output [2:0] sel_ext,
    //--Exclusively a Controller output--
    output we_pc
);

//--FSM--
wire [3:0] state;
wire pc_update;
wire branch;
wire [1:0] alu_op;

fsm fsm (
    .clk(clk),
    .op(op),
    .reset_n(reset_n),
    .state(state),
    .sel_result(sel_result),
    .sel_alu_src_a(sel_alu_src_a),
    .sel_alu_src_b(sel_alu_src_b),
    .we_pc(we_pc),
    .sel_mem_addr(sel_mem_addr),
    .we_mem(we_mem),
    .we_ir(we_ir),
    .we_rf(we_rf),
    .alu_op(alu_op),
    .pc_update(pc_update),
    .branch(branch)
);

alu_decoder alu_decoder (
    .funct3(funct3),
    .funct7(funct7),
    .alu_op(alu_op),
    .alu_control(alu_control)
);

instruction_decoder instruction_decoder(
    .op(op),
    .sel_ext(sel_ext)
);

//Gates
assign we_pc = (zero & branch) | pc_update;

endmodule