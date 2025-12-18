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
    wire [31:0] rd1;
    wire [31:0] rd2;

    //Instantiation
    register_file dut(
        .clk_r(clk),
        .reset_n(reset_n),
        .a1(a1),
        .a2(a2),
        .a3(a3),
        .wd3(wd3),
        .we3(we3),
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
        $dumpvars(0, regfile_tb);
    end

    //Main test
    initial begin
        //initialize input
        reset_n = 0; 
        a1 = 0; a2 = 0; a3 = 0; we3 = 0; wd3 = 0;

        @(posedge clk);
        @(posedge clk);

        reset_n = 1;

        //Test 1: Write to a register ADDI x%, x0, 10
        $display("Test 1: Write data. Expected - Registers[5] = 10");
        a3 =5; 
        wd3 = 10;
        we3 = 1;
        @(posedge clk);
        #1;
        we3 = 0;

        //Test 2: Write to another register ADDI x6, x0, 42
        $display("Test 2: Write to another reg. Expected - Registers[6] = 42");
        a3 = 6;
        wd3 = 42;
        we3 = 1;
        @(posedge clk);
        #1;

        //Test 3: Read 2 registers ADD x7, x5, x6
        $display("Test 3: Read two regs");
        we3 = 0;
        a1 = 5; 
        a2 = 6; 
        @(posedge clk);
        #1;

        a3 = 7;
        wd3 = rd1 + rd2;
        we3 = 1;
        @(posedge clk);
        we3 = 0;

        //Test 4: write to x0 -- should not change x0
        $display("Test 4: Write to x0");
        a3 = 0; 
        wd3 = 123; 
        we3 = 1;
        @(posedge clk);
        we3 = 0;

        //Test 5: Reset reg file
        //$display("Test 5: Reset reg file");
        //reset_n = 1; 
        //@(posedge clk);
        //reset_n = 0; 

        $finish;
    end

    initial begin
        $monitor("Time=%0t | rd1=%d | rd2=%d | a3=%d | wd3=%d | write enable=%b", 
         $time, rd1, rd2, a3, wd3, we3);
    end

endmodule