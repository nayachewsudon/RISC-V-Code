`timescale 1ns/1ps
`include "components.v"

module im_tb();
    //Inputs
    reg [31:0] a_im;
    
    //Output
    wire [31:0] out_im;

    instruction_memory dut(
        .a_im(a_im),
        .rd_im(out_im)
    );

    initial begin
        $dumpfile("im_dump.vcd");
        $dumpvars(0, im_tb);
    end

    initial begin
        //Test 1: Get x0
        a_im= 0; 
        $display("Test 1: Get x0");

        #10;

        //Test 2: Get x42
        a_im = 32'd42;
        $display("Test 2: Get x42");

        #10;

        //Test 3: Get x63
        a_im = 32'd63;
        $display("Test 3: Get x63");
        
    end

    initial begin
        $monitor("IM input= %b | IM output = %b",
         a_im, out_im);
    end


endmodule