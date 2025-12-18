`timescale 1ns/1ps
`include "alu.v"

module alu_tb ();

    //DUT Inputs
    reg [31:0] a;
    reg [31:0] b;
    reg [3:0] alu_controller;

    //DUT Outputs
    wire [31:0] alu_result;
    wire zero;

    //DUT Instantiation
    alu dut (
        .a(a),
        .b(b),
        .alu_controller(alu_controller),
        .alu_result(alu_result),
        .zero(zero)
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
        $display("a = %h, b = %h, addition operation result = %h", a, b, alu_result);

        //Case 2: sll
        a = 32'h12345678;
        b = 32'h0066426A;
        alu_controller = 4'b0001;
        #1
        $display("a = %h, b = %h, output shift left log = %h", a, b, alu_result);

        //Case 3: slt
        a = 32'h00345678;
        b = 32'h0066426A;
        alu_controller = 4'b0010;
        #1
        $display("a = %h, b = %h, output slt = %h", a, b, alu_result);

        //Case 4: sra
        a = 32'h12345678;
        b = 32'h00111111;
        alu_controller = 4'b1101;
        #1
        $display("a = %h, b = %h, output sra = %h", a, b, alu_result);

        //Case 5: default
        a = 32'h12345678;
        b = 32'h0066426A;
        alu_controller = 4'b1111;
        #1
        $display("a = %h, b = %h, output default = %h", a, b, alu_result);

        //Case 6: xor
        a = 32'h013823F4;
        b = 32'h0021293A;
        alu_controller = 4'b0100;
        #1
        $display("a = %h, b = %h, output xor = %h", a, b, alu_result);

        //Case 7: Raise zero flag
        a = 32'hDEADBEEF;
        b = 32'hDEADBEEF;
        alu_controller = 4'b1000;
        #1;
        $display("a = %h, b = %h, output sub = %h, flag yes no = %b", a, b, alu_result, zero);

        //Case 8: sub resulting in negative
        a = 32'h00000001;
        b = 32'h00000002;
        alu_controller = 4'b1000; //sub
        #1; 
        $display("a = %h, b = %h, result should wrap = %h", a, b, alu_result);

        //Case 9: slt with negative numbers
        a = 32'hFFFFFFFF; //-1
        b = 32'b00000001; //1
        alu_controller = 4'b0010;
        #1; 
        $display("a = %h, b = %h, slt result (should be b) = %h", a, b, alu_result);

        //Case 10: sltu with same values
        a = 32'hFFFFFFFF; //-1
        b = 32'b00000001; //1
        alu_controller = 4'b0011;
        #1; 
        $display("a = %h, b = %h, sltu result (should b 0, unsigned) = %h", a, b, alu_result);

        //Case 11: SRA with negative number 
        a = 32'h80000000;
        b = 32'h00000001;
        alu_controller = 4'b1101;
        #1; 
        $display("a = %h, b = %h, sra result (should be 0XC0000000) = %h", a, b, alu_result);
    end

endmodule