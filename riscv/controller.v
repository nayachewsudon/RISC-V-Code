`include "alu_decoder.v"
`include "fsm.v"
`include "instruction_decoder.v"

module controller(
    input [6:0] op, 
    input [2:0] funct3,
    input funct7,
    output we_pc
    //--FSM OUTPUTS--
    output sel_result,
    output sel_alu_src_b,
    output sel_alu_src_a,
    output we_pc,
    output sel_mem_addr,
    output we_mem,
    output we_ir,
    output sel_ext,
    output we_rf,
    //--ALU DECODER OUTPUT--
    output [3:0] alu_control,
    //--INSTRUCTION DECODER OUTPUT --
    output [2:0] sel_ext
);

//--FSM--

endmodule