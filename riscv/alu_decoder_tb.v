`timescale 1ns/1ps
`include "alu_decoder.v"

module alu_decoder_tb ();

    // DUT Inputs
    reg [6:0] op;
    reg [2:0] funct3;
    reg [1:0] alu_op; 
    reg funct7;

    // Outputs
    wire [3:0] alu_control;

    // DUT Instantiation
    alu_decoder dut (
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .alu_control(alu_control)
    );

    //Waveform dump
    initial begin
        $dumpfile("alu_decoder_dump.vcd");
        $dumpvars(0, alu_decoder_tb);
    end

    initial begin
        //R-TYPE (alu_op = 10)
        funct3 = 3'b000; funct7 = 1'b0; alu_op = 2'b10;
        #1;
        $display("ADD: alu_control = %b (expected 0000)", alu_control);

        funct7 = 1;
        #1;
        $display("SUB: alu_control = %b (expected 1000)", alu_control);
        
        //I-type (alu_op = 10)
        funct3 = 3'b000; funct7 = 1'b0; alu_op = 2'b10;
        #1;
        $display("ADDI: alu_control = %b (expected 0000)", alu_control);

        //lw (alu_op = 00)
        funct3 = 3'b000; funct7 = 1'b0; alu_op = 2'b00;
        #1;
        $display("LW: alu_control = %b (expected 0000)", alu_control);

        //sw (alu_op = 00)
        funct3 = 3'b000; funct7 = 1'b0; alu_op = 2'b00;
        #1;
        $display("SW: alu_control = %b (expected 0000)", alu_control);

        //beq (alu_op = 01 for branch)
        funct3 = 3'b000; funct7 = 1'b1; alu_op = 2'b01;
        #1;
        $display("BEQ: alu_control = %b (expected 1000 for SUB)", alu_control);

        //lui (alu_op = 00)
        funct3 = 3'bxxx; funct7 = 1'b0; alu_op = 2'b00;
        #1;
        $display("LUI: alu_control = %b (expected 0000)", alu_control);

        //jal (alu_op = 00)
        funct3 = 3'bxxx; funct7 = 1'b0; alu_op = 2'b00;
        #1;
        $display("JAL: alu_control = %b (expected 0000)", alu_control);
        
        $finish;
    end
endmodule