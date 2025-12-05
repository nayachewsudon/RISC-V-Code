`timescale 1ns/1ps
`include "components.v"

module adder_tb();
    //DUT Inputs
    reg [31:0] pc; 

    //Output
    wire [31:0] pc_plus_4;

    //DUT Instantiation

    adder dut (
        .pc(pc),
        .pc_plus_4(pc_plus_4)
    );

    //Waveform dump
    initial begin
        $dumpfile("adder_dump.vcd");
        $dumpvars(0, adder_tb);
    end

    //Main test
    initial begin
        //Test 1: Add 4
        pc = 32'd0;
        $display("Test 1: Add 4 to 32'b0");
        #10;

        //Test 2: Add 4 to 32'h00000004
        pc = 32'h00000004;
        $display("Test 2: Add 4 to 32'h00000004");
        #10;

        //Test 3: Add 4 to 32'hFFFFFFFF;
        pc = 32'hFFFFFFFF;
        $display("Test 3: Add 4 to 32'hFFFFFFFF");
        #10;
    end

    initial begin
        $monitor("PC In=%b| Adder out = %b",
        pc, pc_plus_4); 
    end

endmodule