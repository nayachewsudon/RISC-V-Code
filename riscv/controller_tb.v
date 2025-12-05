`timescale 1ns/1ps
`include "controller.v"

module controller_tb ();

    // DUT Inputs
    reg [6:0] op;
    reg [2:0] funct3;
    reg funct7; // note: only bit 5 of funct7

    // Outputs
    wire [1:0] sel_result;
    wire dmem_we, sel_alu_src_b, rf_we, branch, sel_jump;
    wire [2:0] sel_ext;
    wire [1:0] alu_op;
    wire [3:0] alu_control;

    // DUT Instantiation
    controller_stageone stage1 (
        .op(op),
        .sel_result(sel_result),
        .sel_alu_src_b(sel_alu_src_b),
        .dmem_we(dmem_we),
        .sel_ext(sel_ext),
        .rf_we(rf_we),
        .branch(branch),
        .sel_jump(sel_jump),
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

        //beq
        op = 7'b1100011; funct3 = 3'b000; funct7 = 1'b1; // SUB used for comparison
        #1;
        $display("BEQ: alu_control = %b", alu_control);
        $display("opcode=%b branch=%b sel_jump=%b alu_op=%b", 
                 op, branch, sel_jump, alu_op);

        //lui
        op = 7'b0110111; funct3 = 3'bxxx; funct7 = 0;
        #1;
        $display("LUI: alu_control = %b", alu_control);
        $display("opcode=%b sel_result=%b sel_alu_src_b=%b rf_we=%b alu_op=%b", 
                 op, sel_result, sel_alu_src_b, rf_we, alu_op);

        //jal
        op = 7'b1101111; funct3 = 3'bxxx; funct7 = 0;
        #1;
        $display("JAL: alu_control = %b", alu_control);
        $display("opcode=%b sel_result=%b sel_jump=%b rf_we=%b alu_op=%b", 
                 op, sel_result, sel_jump, rf_we, alu_op);
    end
endmodule