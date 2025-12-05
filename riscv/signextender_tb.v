`timescale 1ns/1ps
`include "signextender.v"

module signextender_tb();

    // Inputs
    reg [31:7] A;
    reg [1:0] sel_ext;

    // Output
    wire [31:0] out;

    // DUT instantiation
    signextender dut(
        .A(A),
        .sel_ext(sel_ext),
        .out(out)
    );

    // Waveform dump
    initial begin
        $dumpfile("signextender_dump.vcd");
        $dumpvars(0, signextender_tb);
    end

    // Main test
    initial begin
        A = 25'h000ABC;
        sel_ext = 2'b00;
        #1;
        $display("Test lw: A=%h sel_ext=%b => out=%h", A, sel_ext, out);

        A = 25'hFFF123;  
        sel_ext = 2'b10;
        #1;
        $display("Test I-type (neg): A=%h sel_ext=%b => out=%h", A, sel_ext, out);

        A = 25'h0ABCD;  
        sel_ext = 2'b01;
        #1;
        $display("Test sw: A=%h sel_ext=%b => out=%h", A, sel_ext, out);

        A = 25'h12345;  
        sel_ext = 2'b11;
        #1;
        $display("Test R-type: A=%h sel_ext=%b => out=%h", A, sel_ext, out);

        $finish;
    end

endmodule
