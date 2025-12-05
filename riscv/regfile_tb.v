`timescale 1ns/1ps
`include "components.v"

module regfile_tb();

    //Inputs
    reg clk;
    reg reset_n;
    reg [4:0] a1;
    reg [4:0] a2;
    reg [4:0] a3;
    reg [31:0] wd3;
    reg we3; //write enable bit

    //Outputs
    reg [31:0] rd1;
    reg [31:0] rd2;

    //Instantiation
    register_file dut(
        .clk_r(clk),
        .reset_r(reset_n),
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .wd3(wd3),
        .rd1(rd1),
        .rd2(rd2)
    );
    //Generate clock
    initial begin
        clk = 0; 
        forever #5 clk = ~clk;
    end

    //Waveform dump
    initial begin
        $dumpfile("regfile_dump.vcd");
        $dumpvars(0, pc_tb);
    end

    //Main test
    initial begin
        //initialize input
        reset_n = 1; a1, a2, a3 = 0;

        @(posedge clk);
        @(posedge clk);

        reset_n = 0;

        //Test 1:
        //Test 2:
    end

endmodule