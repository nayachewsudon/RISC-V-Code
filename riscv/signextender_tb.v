`timescale 1ns/1ps
`include "signextender.v"

module signextender_tb();

    // Inputs
    reg [24:0] A;
    reg [2:0] sel_ext;

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
        sel_ext = 3'b000; 
        #1;
        $display("I-type/LW: A=%h sel_ext=%b => out=%h", A, sel_ext, out);

        A = 25'hFFF123; 
        sel_ext = 3'b000; 
        #1;
        $display("I-type/LW (negative): A=%h sel_ext=%b => out=%h", A, sel_ext, out);

        A = 25'h0ABCD; 
        sel_ext = 3'b001; 
        #1;
        $display("SW: A=%h sel_ext=%b => out=%h", A, sel_ext, out);

        A = 25'h12345; 
        sel_ext = 3'b011; 
        #1;
        $display("B-type/BEQ: A=%h sel_ext=%b => out=%h", A, sel_ext, out);

        A = 25'h1ABCDE; 
        sel_ext = 3'b100; 
        #1;
        $display("J-type/JAL: A=%h sel_ext=%b => out=%h", A, sel_ext, out);

        A = 25'h0FEDC; 
        sel_ext = 3'b101; 
        #1;
        $display("U-type/LUI: A=%h sel_ext=%b => out=%h", A, sel_ext, out);
        $finish;
    end

endmodule
