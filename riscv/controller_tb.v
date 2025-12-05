`timescale 1ns/1ps
`include "controller.v"

module controller_tb ();

    //DUT Inputs
    reg [6:0] op;
    reg [2:0] funct3;
    reg funct7;

    //Outputs
    wire sel_result, dmem_we, sel_alu_src_b, rf_we;
    wire [1:0] sel_ext, alu_op;
    wire [3:0] alu_control;

    //DUT Instantiation
    controller_stageone stage1 (
        .op(op),
        .sel_result(sel_result),
        .sel_alu_src_b(sel_alu_src_b),
        .dmem_we(dmem_we),
        .sel_ext(sel_ext),
        .rf_we(rf_we),
        .alu_op(alu_op)
    );

    controller_stagetwo stage2 (
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .alu_control(alu_control)
    );

    //Waveform dump
    initial begin
        $dumpfile("controller_dump.vcd");
        $dumpvars(0, controller_tb);
    end

    initial begin
        //R-TYPE
        op = 7'b0110011; funct3 = 3'b000; funct7 = 0;
        #1;
        $display("ADD: alu_control = %b", alu_control);
        $display("opcode=%b sel_result=%b dmem_we=%b sel_alu_src_b=%b rf_we=%b alu_op=%b", 
        op, sel_result, dmem_we, sel_alu_src_b, rf_we, alu_op);

        funct7 = 1;
        #1;
        $display("SUB: alu_control = %b", alu_control);
        
        //I-type
        op = 7'b0010011; funct3 = 3'b000; funct7 = 0;
        #1;
        $display("ADDI: alu_control = %b", alu_control);
        $display("opcode=%b sel_result=%b dmem_we=%b sel_alu_src_b=%b rf_we=%b alu_op=%b", 
        op, sel_result, dmem_we, sel_alu_src_b, rf_we, alu_op);

        //lw
        op = 7'b0000011; funct3 = 3'b000; funct7 = 0;
        #1;
        $display("lw: alu_control = %b", alu_control);
        $display("opcode=%b sel_result=%b dmem_we=%b sel_alu_src_b=%b rf_we=%b alu_op=%b", 
        op, sel_result, dmem_we, sel_alu_src_b, rf_we, alu_op);

        //sw
        op = 7'b0100011; funct3 = 3'b000; funct7 = 0;
        #1;
        $display("sw: alu_control = %b", alu_control);
        $display("opcode=%b sel_result=%b dmem_we=%b sel_alu_src_b=%b rf_we=%b alu_op=%b", 
        op, sel_result, dmem_we, sel_alu_src_b, rf_we, alu_op);
    end
endmodule