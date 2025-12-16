`timescale 1ns/1ps
`include "alu.v"

module alu_tb ();

    //DUT Inputs
    reg [31:0] a;
    reg [31:0] b;
    reg [3:0] alu_controller;

    //DUT Outputs
    wire [31:0] rd;
    wire zero_flag;

    //DUT Instantiation
    alu dut (
        .a(a),
        .b(b),
        .alu_controller(alu_controller),
        .rd(rd),
        .zero_flag(zero_flag)
    );

    //Waveform dump
    initial begin
        $dumpfile("alu_dump.vcd");
        $dumpvars(0, alu_tb);
    end

    initial begin
        //Case 1: add, should wrap around
        a = 32'h12345678;
        b = 32'h87654321;
        alu_controller = 4'b0000;
        #1
        $display("a = %d, b = %d, output add = %d", a, b, rd);

        //Case 2: sll
        a = 32'h12345678;
        b = 32'h0066426A;
        alu_controller = 4'b0001;
        #1
        $display("a = %d, b = %d, output shift left log = %d", a, b, rd);

        //Case 3: slt
        a = 32'h00345678;
        b = 32'h0066426A;
        alu_controller = 4'b0010;
        #1
        $display("a = %d, b = %d, output slt = %d", a, b, rd);

        //Case 4: sra
        a = 32'h12345678;
        b = 32'h00111111;
        alu_controller = 4'b1101;
        #1
        $display("a = %d, b = %d, output sra = %d", a, b, rd);

        //Case 5: default
        a = 32'h12345678;
        b = 32'h0066426A;
        alu_controller = 4'b1111;
        #1
        $display("a = %d, b = %d, output default = %d", a, b, rd);

        //Case 6: xor
        a = 32'h013823F4;
        b = 32'h0021293A;
        alu_controller = 4'b0100;
        #1
        $display("a = %b, b = %b, output xor = %b", a, b, rd);
    end

endmodule