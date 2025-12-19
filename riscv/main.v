`include "components.v"
`include "controller.v"
`include "signextender.v"
`include "alu.v"

module rv_mc(
    input clk, 
    input rst
);

//--Nonarchitectural registers--
reg [31:0] pc_reg; 
reg [31:0] instr_reg;
reg [31:0] old_pc_reg;
reg [31:0] rd1_reg;
reg [31:0] rd2_reg;
reg [31:0] alu_reg;
reg [31:0] data_reg;

//--PC_REG--
always @ (posedge clk or negedge rst) begin 
        if (!rst) begin
            pc_reg <= 32'hFFFFFFFC;//reset value
        end
        else if (we_pc) begin
            pc_reg <= mux4_output; //Output of mux 4 is used for pc_reg
        end
    end

//--OLD_PC and INSTR_REG
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        instr_reg <= 32'b0; 
        old_pc_reg <= 32'b0; 
    end
    else if (we_ir) begin
        instr_reg <= read_data; //From memory 
        old_pc_reg <= pc_reg; 
    end
end

//-- RD1_REG dan RD2_REG
always @(posedge clk) begin
       rd1_reg <= rd1;
        rd2_reg <= rd2; 
    end

//--ALU_REG
always @(posedge clk) begin
        alu_reg <= alu_output; //Output from ALU
end

//--DATA_REG
always @(posedge clk) begin
        data_reg <= read_data; //Output from ALU
end

//--Controller
wire [1:0] sel_result;
wire [1:0] sel_alu_src_b;
wire [1:0] sel_alu_src_a;
wire sel_mem_addr;
wire we_mem;
wire we_ir;
wire we_rf;
//--ALU DECODER OUTPUT--
wire [3:0] alu_control;
//--INSTRUCTION DECODER OUTPUT --
wire [2:0] sel_ext;
//--Exclusively a Controller output--
wire we_pc;

controller controller (
    .clk(clk),
    .reset_n(rst),
    .zero(zero),
    .op(instr_reg[6:0]), //taken from instruction_output of pc
    .funct3(instr_reg[14:12]),
    .funct7(instr_reg[30]), //!!!: Bisa jadi sumber error 
    .sel_result(sel_result),
    .sel_alu_src_a(sel_alu_src_a),
    .sel_alu_src_b(sel_alu_src_b),
    .sel_mem_addr(sel_mem_addr),
    .we_mem(we_mem),
    .we_ir(we_ir),
    .we_rf(we_rf),
    .alu_control(alu_control),
    .sel_ext(sel_ext),
    .we_pc(we_pc)
);

//--Multiplexer 1
wire [31:0] mux1_output;

mux_2to1 mux_1(
    .in_a(pc_reg), //input from pc_reg
    .in_b(mux4_output), //input from mux 4
    .sel(sel_mem_addr),
    .out_m(mux1_output)
);

//--Memory--
wire [31:0] read_data;

mem MEM
(
    .addr_memory(mux1_output), //input from mux 1
    .writedata(rd2_reg), //Input rd2_reg, nanti sesuaikan di diagram
    .we_mem(we_mem), //input from the controller
    .clk(clk), //deleted reset
    .read_data(read_data)
);

//--Register File--
wire [31:0] rd1;
wire [31:0] rd2;

register_file register_file (
    .clk_r(clk),
    .reset_n(rst),
    .a1(instr_reg[19:15]),
    .a2(instr_reg[24:20]),
    .a3(instr_reg[11:7]),
    .wd3(mux4_output),
    .rd1(rd1),
    .rd2(rd2),
    .we3(we_rf) 
);

//--Sign Extender --
wire [31:0] se_out;

signextender signextender(
    .A(instr_reg[31:7]),
    .sel_ext(sel_ext),
    .out(se_out)
);

//--Multiplexer 2
wire [31:0] mux2_output;
mux_3to1 mux_2(
    .in_a(pc_reg), //input from incremented pc
    .in_b(old_pc_reg), //input from OldPc
    .in_c(rd1_reg), //Input from RD1_reg
    .sel(sel_alu_src_a),
    .out_m(mux2_output)
);

//--Multiplexer 3
wire [31:0] mux3_output; 
mux_3to1_offset mux_3(
    .in_a(rd2_reg), //input from rd2_reg
    .in_b(se_out),
    .sel(sel_alu_src_b),
    .out(mux3_output)
);

//--ALU--
wire [31:0] alu_output;
wire zero; 
alu alu(
    .a(mux2_output),
    .b(mux3_output),
    .alu_controller(alu_control),
    .alu_result(alu_output),
    .zero(zero)
);

//--Multiplexer 4
wire [31:0] mux4_output;
mux_3to1 mux_4(
    .in_a(alu_reg), //input from alu_reg
    .in_b(data_reg), //input from data_reg
    .in_c(alu_output), //alu_result from alu
    .sel(sel_result),
    .out_m(mux4_output)
);

endmodule