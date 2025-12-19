`timescale 1ns/1ps
`include "main.v"

module testbench;

reg clk;
reg rst;

rv_mc riscv_mc_inst (
    .clk(clk),
    .rst(rst)
);

// Shadow register file
reg [31:0] regfile_shadow [0:31];
integer i;

// Clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Initialize memory
initial begin
    $readmemh("test.hex", riscv_mc_inst.MEM.RAM);
end

// Reset and run
initial begin
    $dumpfile("riscv_test.vcd");
    $dumpvars(0, riscv_mc_inst);

    rst = 0;      
    #20;
    rst = 1; 

    // Initialize shadow
    for (i = 0; i < 32; i = i + 1)
        regfile_shadow[i] = 0;

    #10000; // Increased time to handle JAL loops

    $display("\n=== FINAL REGISTER DUMP ===");
    $display("x1  (LUI)        = 0x%h  (expect 0x12345000)  | %s", regfile_shadow[1], (regfile_shadow[1]==32'h12345000) ? "OK" : "WRONG");
    $display("x2  (ADDI 10)    = %0d   (expect 10)          | %s", regfile_shadow[2], (regfile_shadow[2]==10) ? "OK" : "WRONG");
    $display("x3  (ADDI 20)    = %0d   (expect 20)          | %s", regfile_shadow[3], (regfile_shadow[3]==20) ? "OK" : "WRONG");
    $display("x4  (ADDI -5)    = %0d   (expect -5)          | %s", $signed(regfile_shadow[4]), ($signed(regfile_shadow[4])==-5) ? "OK" : "WRONG");
    $display("x5  (ADD)        = %0d   (expect 30)          | %s", regfile_shadow[5], (regfile_shadow[5]==30) ? "OK" : "WRONG");
    $display("x6  (SUB)        = %0d   (expect 10)          | %s", regfile_shadow[6], (regfile_shadow[6]==10) ? "OK" : "WRONG");

    // Comparisons
    $display("x10 (SLT)        = %0d   (expect 1)           | %s", regfile_shadow[10], (regfile_shadow[10]==1) ? "OK" : "WRONG");
    $display("x11 (SLTU)       = %0d   (expect 0)           | %s", regfile_shadow[11], (regfile_shadow[11]==0) ? "OK" : "WRONG");

    // Branch and jump - FIXED EXPECTATIONS
    $display("x15 (BEQ flag)   = %0d   (expect 99)          | %s", regfile_shadow[15], (regfile_shadow[15]==99) ? "OK" : "WRONG");
    $display("x16 (BEQ taken)  = %0d   (expect 2)           | %s", regfile_shadow[16], (regfile_shadow[16]==2) ? "OK" : "WRONG");
    
    // JAL x17: saves return address 0x4C+4=0x50, jumps to 0x08
    $display("x17 (JAL link)   = 0x%h  (expect 0x00000050)  | %s", regfile_shadow[17], (regfile_shadow[17]==32'h00000050) ? "OK" : "WRONG");
    
    // After JAL jumps to 0x08, it re-executes and eventually reaches instruction 21
    $display("x19 (after JAL)  = %0d   (expect 77)          | %s", regfile_shadow[19], (regfile_shadow[19]==77) ? "OK" : "WRONG");

    // Extended instructions
    $display("x20 (new LUI)    = 0x%h  (expect 0xABCDE000)  | %s", regfile_shadow[20], (regfile_shadow[20]==32'hABCDE000) ? "OK" : "WRONG");
    $display("x21 (SRA x3>>x2) = 0x%h  (expect 0x00000000)  | %s", regfile_shadow[21], (regfile_shadow[21]==32'h00000000) ? "OK" : "WRONG");
    $display("x22 (ADD x20+x21)= 0x%h  (expect 0xABCDE000)  | %s", regfile_shadow[22], (regfile_shadow[22]==32'hABCDE000) ? "OK" : "WRONG");
    $display("x23 (SUB x21-x22)= 0x%h  (expect 0x54322000)  | %s", regfile_shadow[23], (regfile_shadow[23]==32'h54322000) ? "OK" : "WRONG");
    $display("x24 (SLTU)       = %0d   (expect 0)           | %s", regfile_shadow[24], (regfile_shadow[24]==0) ? "OK" : "WRONG");
    $display("x25 (AND x22,x23)= 0x%h  (expect 0x00002000)  | %s", regfile_shadow[25], (regfile_shadow[25]==32'h00002000) ? "OK" : "WRONG");
    $display("x26 (OR x24,x25) = 0x%h  (expect 0x00002000)  | %s", regfile_shadow[26], (regfile_shadow[26]==32'h00002000) ? "OK" : "WRONG");
    $display("x27 (XOR x26,x21)= 0x%h  (expect 0x00002000)  | %s", regfile_shadow[27], (regfile_shadow[27]==32'h00002000) ? "OK" : "WRONG");
    $display("x28 (SLT x27,x22)= %0d   (expect 1)           | %s", regfile_shadow[28], (regfile_shadow[28]==1) ? "OK" : "WRONG");

    $display("\n=== TEST COMPLETE ===");
    $finish;
end

// Track register writes
always @(posedge clk) begin
    if (riscv_mc_inst.we_rf) begin
        regfile_shadow[riscv_mc_inst.instr_reg[11:7]] <= riscv_mc_inst.mux4_output;
    end
end

// Optional: print memory contents at start
initial begin
    #30;
    $display("\n=== MEMORY CONTENTS (first 10 words) ===");
    for (i = 0; i < 10; i = i + 1) begin
        $display("MEM[%0d] = 0x%h", i, riscv_mc_inst.MEM.RAM[i]);
    end
end

// Timeout
initial begin
    #20000;
    $display("ERROR: Simulation timeout!");
    $finish;
end

endmodule