`timescale 1ns/1ps
`include "components.v"

module dm_tb ();

    //DUT Inputs
    reg [31:0] a_dm;
    reg clk_dm;
    reg reset_dm; 
    reg [31:0] wd_dm;
    reg we;

    //DUT Outputs
    wire [31:0] rd_dm;

    //DUT Instantiation

    data_memory dut (
        .a_dm(a_dm),
        .clk_dm(clk_dm),
        .reset_dm(reset_dm),
        .wd_dm(wd_dm),
        .we(we),
        .rd_dm(rd_dm)
    );

    //Generate clock
    initial begin
        clk_dm = 0; 
        forever #5 clk_dm = ~clk_dm;
    end

    //Waveform dump
    initial begin
        $dumpfile("dm_dump.vcd");
        $dumpvars(0, dm_tb);
    end

    //Main test
    initial begin
        a_dm = 0; 
        wd_dm = 0; 
        we = 0 ;
        reset_dm = 1; //initialize mem
        @(posedge clk_dm);
        reset_dm = 0; 

        $display("Test 1: Write + read value 1");
        a_dm = 4;
        we = 1; 
        wd_dm = 32'hDEADBEEF;
        @(posedge clk_dm);
        we = 0;
        a_dm = 4; 
        @(posedge clk_dm);
        $display("Read value: %h", rd_dm);

        $display("Test 2: Write n Read value 2");
        a_dm = 5;
        we = 1; 
        wd_dm = 32'h0F0F0F0F;
        @(posedge clk_dm);
        we = 0;
        a_dm = 5; 
        @(posedge clk_dm);
        $display("Read value: %h", rd_dm);

        $display("Test 3: Write n Read value 2");
        a_dm = 6; 
        we = 1; 
        wd_dm  = 32'h12345678;
        @(posedge clk_dm);
        we = 0;
        a_dm = 6; 
        @(posedge clk_dm);
        $display("Read value: %h", rd_dm);

        $display("Test 4: Write with we = 0"); 
        a_dm = 7; 
        wd_dm = 32'h87654321;
        we = 0; 

        @(posedge clk_dm);
        a_dm = 7; //baca
        $display("Read value: %h", rd_dm);

        $display("Test 5: Reset mem");
        reset_dm = 1;
        @(posedge clk_dm);
        reset_dm = 0; 
        @(posedge clk_dm);
        a_dm = 6;
        $display("Read value: %h", rd_dm);
        $finish;
    end

    initial begin
        $monitor("Time=%0t | a_dm=%d | rd_dm=%d | wd_dm=%d",
         $time, a_dm, rd_dm, wd_dm);
    end

endmodule