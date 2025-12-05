`timescale 1ns/1ps
`include "components.v"

module mux_tb (); 
    //DUT Inputs
    reg [31:0] in_a, in_b; 
    reg sel;
    
    //DUT output
    wire [31:0] out_m; 

    //instantiation
    multiplexer dut (
        .in_a(in_a),
        .in_b(in_b),
        .sel(sel),
        .out_m(out_m)
    );

    //waveform
    initial begin
        $dumpfile("mux_dump.vcd");
        $dumpvars(0, mux_tb);
    end

    initial begin
        //Test 1: Choose input a
        $display("Choose input a");
        in_a = 32'h00011110; in_b = 32'h1A2B3C4D;
        sel = 1;
        #10;

        //Test b: choose b
        $display("Choose input b");
        sel = 0;
        #10;
    end

    initial begin
        $monitor("Input a= %b, Input b = %b, sel= %b, output= %b",
         in_a, in_b, sel, out_m);
    end
endmodule