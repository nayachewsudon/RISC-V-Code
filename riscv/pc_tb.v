`timescale 1ns/1ps
`include "components.v"

module pc_tb ();

    //DUT Inputs
    reg clk_pc; 
    reg reset_pc;
    reg [31:0] in_pc;

    //DUT Outputs
    wire [31:0] out_pc;

    //DUT Instantiation

    programcounter dut (
        .clk_pc(clk_pc),
        .in_pc(in_pc),
        .reset_pc(reset_pc),
        .out_pc(out_pc)
    );

    //Generate clock
    initial begin
        clk_pc = 0; 
        forever #5 clk_pc = ~clk_pc;
    end

    //Waveform dump
    initial begin
        $dumpfile("pc_dump.vcd");
        $dumpvars(0, pc_tb);
    end

    //Main test
    initial begin
        //initialize inputs
        reset_pc = 1; in_pc = 0;     

        @(posedge clk_pc);
        @(posedge clk_pc);

        reset_pc = 0;
       
        //test 1: load pc w 4
        $display("Test 1: Load PC with 4");
        in_pc = 4; 

        @(posedge clk_pc);

        //test 2: load with 12
        $display("Test 2: Load PC with 12");
        in_pc = 12;

        @(posedge clk_pc);

        //test 3: load hex
        $display("Test 3: Load PC with 32'h00011110");
        in_pc = 32'h00011110;

        //test 4: reset
        $display("Test 4: Reset");
        reset_pc = 1; 
        @(posedge clk_pc);
        reset_pc = 0;

        #50
        $finish;
    end

    initial begin
        $monitor("Time=%0t | reset=%b | pc_in=%b | pc_out=%b",
         $time, reset_pc, in_pc, out_pc);
    end

endmodule