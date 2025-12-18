`timescale 1ns/1ps
`include "components.v"

module memory_tb(); 
//Inputs
    reg [31:0] addr_memory;
    reg [31:0] writedata;
    reg we_mem;
    reg clk;
    reg reset_n;
    
//Outputs
    wire [31:0] read_data;

//DUT Instantiation
    mem dut(
        .addr_memory(addr_memory),
        .writedata(writedata),
        .we_mem(we_mem),
        .clk(clk),
        .reset_n(reset_n),
        .read_data(read_data)
    );

//Waveform dump 

    initial begin
        $dumpfile("memory_dump.vcd");
        $dumpvars(0, memory_tb);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

   initial begin
        reset_n = 0; addr_memory = 0; writedata = 0; we_mem = 0;

        @(posedge clk); 
        @(posedge clk);
        reset_n = 1; 
        @(posedge clk);

        //Test 1
        $display ("Test 1: Read initial memory contents");
        addr_memory = 32'h00000000;
        #1; 
        $display("Address 0x00: read_data = 0x%h", read_data);

        @(posedge clk);
        addr_memory = 32'h00000004; 
        #1; 
        $display("Address 0x04: read_data = 0x%h", read_data);

        //Test 2
        $display("Test 2: Write to mem"); 
        @(posedge clk);
        addr_memory = 32'h00000010;
        we_mem = 1;
        writedata = 32'hDEADBEEF;
        @(posedge clk); 
        we_mem = 0;

        #1; 
        $display("Write to 0x10: read_data = 0x%h (expecting 0xDEADBEEF)", read_data);

        //Test 3;
        $display("Test 3: Write to another location");
        @(posedge clk); 
        addr_memory = 32'h00000014;
        writedata = 32'hBEEFDEAD;
        we_mem = 1;
        @(posedge clk);
        we_mem = 0;

        #1; 
        $display("Write to 0x14: read_data = 0x%h (expected 0xBEEFDEAD)", read_data);

        //Test 4;
        $display("Test 4: Read and Modify data");
        @(posedge clk);
        writedata = 0;
        addr_memory = 32'h00000020;
        @(posedge clk);
        $display("Data at address 0x20, before mod = 0x%h", read_data);

        writedata = read_data + 1; 
        we_mem = 1;
        @(posedge clk);
        we_mem = 0;

        #1; 
        $display("Data after modification at address 0x20 = 0x%h", read_data);
        we_mem = 0; 

        //Test 5
        $display("Test 5: Verify that write enable works");
        @(posedge clk); 
        addr_memory = 32'h00000010; 
        #1; 
        $display("Showing data at 0x10 before rewrite, I wrote DEADBEEF here = 0x%h", read_data);

        @(posedge clk);
        writedata = 32'hCAFEDADD;
        @(posedge clk); 
        $display("Read mem value = 0x%h, should not have been overwritten", read_data);

        //Test 6
        $display("Test 6: Checking that reset works");
        @(posedge clk); 
        addr_memory = 32'h00000014;
        reset_n = 1;
        @(posedge clk);
        $display("Value of address 0x10 = 0x%h, expecting 0xBEEFDEAD from previous test", read_data);
        reset_n = 0;
        @(posedge clk); 
        $display("Value of address 0x10 after reset = 0x%h", read_data);

        #20; 
        $finish;

    end

    initial begin
        $monitor("Time=%0t | addr=0x%h | writedata=0x%h | we_mem=%b | read_data=0x%h", 
                 $time, addr_memory, writedata, we_mem, read_data);
    end
endmodule