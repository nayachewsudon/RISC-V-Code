`timescale 1ns/1ps
`include "main.v"

module testbench;

reg clk;
reg reset;

riscv riscv_inst (
    .clk(clk),
    .reset(reset)
);

// Shadow register file for tracking
reg [31:0] regfile_shadow [0:31];
integer i;
integer addr_index;

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Track register writes
always @(posedge clk) begin
    if (!reset) begin
        for (i = 0; i < 32; i = i + 1) begin
            regfile_shadow[i] <= riscv_inst.register_file.Registers[i];
        end
    end
end

// Initialize memory with test.hex
initial begin
    $readmemh("test.hex", riscv_inst.instruction_memory.Memory);
    
    // Pre-initialize data memory location 0x70 if needed
    // Adjust based on your data memory implementation
    #1
    riscv_inst.data_memory.Memory[32'h70 >> 2] = 32'hDEADBEEF;
end

// Waveform dump
initial begin
    $dumpfile("riscv_test.vcd");
    $dumpvars(0, testbench);
    
    // Reset sequence
    reset = 1;
    #20;
    reset = 0;
    
    $display("=== Instruction Memory Check ===");
    $display("Memory[0] = 0x%h (expect 0x123450b7)", riscv_inst.instruction_memory.Memory[0]);
    $display("Memory[1] = 0x%h (expect 0x00a00113)", riscv_inst.instruction_memory.Memory[1]);
    $display("Memory[2] = 0x%h (expect 0x01400193)", riscv_inst.instruction_memory.Memory[2]);
    $display("Memory[3] = 0x%h (expect 0xffb00213)", riscv_inst.instruction_memory.Memory[3]);

    // Run for sufficient cycles
    #3000;
    
    // Update shadow registers one final time
    for (i = 0; i < 32; i = i + 1) begin
        regfile_shadow[i] = riscv_inst.register_file.Registers[i];
    end
    
    addr_index = 32'h70 >> 2;
        
    $display("\n=== Final Test Results ===");
    $display("=== Basic Instructions ===");
    $display("x1  (LUI)        = 0x%h  (expect 0x12345000)  | %s", regfile_shadow[1], (regfile_shadow[1]==32'h12345000) ? "PASS" : "FAIL");
    $display("x2  (ADDI 10)    = %0d   (expect 10)          | %s", regfile_shadow[2], (regfile_shadow[2]==10) ? "PASS" : "FAIL");
    $display("x3  (ADDI 20)    = %0d   (expect 20)          | %s", regfile_shadow[3], (regfile_shadow[3]==20) ? "PASS" : "FAIL");
    $display("x4  (ADDI -5)    = %0d   (expect -5)          | %s", $signed(regfile_shadow[4]), ($signed(regfile_shadow[4])==-5) ? "PASS" : "FAIL");
    $display("x5  (ADD)        = %0d   (expect 30)          | %s", regfile_shadow[5], (regfile_shadow[5]==30) ? "PASS" : "FAIL");
    $display("x6  (SUB)        = %0d   (expect 10)          | %s", regfile_shadow[6], (regfile_shadow[6]==10) ? "PASS" : "FAIL");
    
    $display("\n=== Logical Instructions ===");
    $display("x7  (ADD)        = %0d   (expect 30)          | %s", regfile_shadow[7], (regfile_shadow[7]==30) ? "PASS" : "FAIL");
    $display("x8  (SLT)        = %0d   (expect 1; signed operation)          | %s", regfile_shadow[8], (regfile_shadow[8]==1) ? "PASS" : "FAIL");
    $display("x9  (SUB)        = %0d   (expect -15)          | %s", $signed(regfile_shadow[9]), ($signed(regfile_shadow[9])==-15) ? "PASS" : "FAIL");
    $display("x10 (SLL)        = %0d   (expect 10240)           | %s", regfile_shadow[10], (regfile_shadow[10]==10240) ? "PASS" : "FAIL");
    $display("x11 (SLTU)       = %0d   (expect 1)           | %s", regfile_shadow[11], (regfile_shadow[11]==1) ? "PASS" : "FAIL");
    $display("x12 (XOR)       = %0h   (expect 0xFFFFFFEF)           | %s", regfile_shadow[12], (regfile_shadow[12]==32'hFFFFFFEF) ? "PASS" : "FAIL");
    $display("x13 (SRL)       = %0d   (expect 0)           | %s", regfile_shadow[13], (regfile_shadow[13]==0) ? "PASS" : "FAIL");
    $display("x14 (OR)       = %0d   (expect 30)           | %s", regfile_shadow[14], (regfile_shadow[14]==30) ? "PASS" : "FAIL");    

    $display("\n=== Branch and Jump ===");
    $display("x15 (BEQ flag)   = %0d   (expect 1)          | %s", regfile_shadow[15], (regfile_shadow[15]==1) ? "PASS" : "FAIL");
    $display("x16 (BEQ taken)  = %0d   (expect 2)           | %s", regfile_shadow[16], (regfile_shadow[16]==2) ? "PASS" : "FAIL");
    $display("x17 (JAL link)   = 0x%h  (expect 0x00000050)  | %s", regfile_shadow[17], (regfile_shadow[17]==32'h00000050) ? "PASS" : "FAIL");
    $display("x19 (after JAL)  = %0d   (expect 0)           | %s", regfile_shadow[19], (regfile_shadow[19]==0) ? "PASS" : "FAIL");
    
    $display("\n=== Extended Instructions ===");
    $display("x20 (LUI)        = 0x%h  (expect 0xabcde000)  | %s", regfile_shadow[20], (regfile_shadow[20]==32'habcde000) ? "PASS" : "FAIL");
    $display("x21 (SRA)        = 0x%h  (expect 0x00000000)  | %s", regfile_shadow[21], (regfile_shadow[21]==32'h00000000) ? "PASS" : "FAIL");
    $display("x22 (ADD)        = 0x%h  (expect 0xabcde000)  | %s", regfile_shadow[22], (regfile_shadow[22]==32'habcde000) ? "PASS" : "FAIL");
    $display("x23 (SUB)        = 0x%h  (expect 0x54322000)  | %s", regfile_shadow[23], (regfile_shadow[23]==32'h54322000) ? "PASS" : "FAIL");
    $display("x24 (SLTU)       = %0d   (expect 0)           | %s", regfile_shadow[24], (regfile_shadow[24]==0) ? "PASS" : "FAIL");
    $display("x25 (AND)        = 0x%h  (expect 0x00002000)  | %s", regfile_shadow[25], (regfile_shadow[25]==32'h00002000) ? "PASS" : "FAIL");
    $display("x26 (OR)         = 0x%h  (expect 0x00002000)  | %s", regfile_shadow[26], (regfile_shadow[26]==32'h00002000) ? "PASS" : "FAIL");
    $display("x27 (XOR)        = 0x%h  (expect 0x00002000)  | %s", regfile_shadow[27], (regfile_shadow[27]==32'h00002000) ? "PASS" : "FAIL");
    $display("x28 (SLT)        = %0d   (expect 0)           | %s", regfile_shadow[28], (regfile_shadow[28]==0) ? "PASS" : "FAIL");
    
    $display("\n=== Memory Operations ===");
    $display("x22 (LUI)        = %0h   (expect 0xdeadb000)           | %s", regfile_shadow[22], (regfile_shadow[22]==32'hdeadb000) ? "PASS" : "FAIL");
    $display("x22 (ADDI x22, x22, -273)        = %0h   (expect 0xdeadaeef)           | %s", regfile_shadow[22], (regfile_shadow[22]==32'hdeadaeef) ? "PASS" : "FAIL");
    $display("x23 (ADDI x23, x0, 0x70)        = %0h   (expect 0x70)           | %s", regfile_shadow[23], (regfile_shadow[23]==32'h70) ? "PASS" : "FAIL");
    $display("Memory[0x70] after SW            = 0x%0h   | %s",
         riscv_inst.data_memory.Memory[addr_index],
         (riscv_inst.data_memory.Memory[addr_index] == 32'h70) ? "PASS" : "FAIL");
    $display("x24 (LW 0(x23))                  = 0x%0h   | %s",
         regfile_shadow[24],
         (regfile_shadow[24] == 32'h70) ? "PASS" : "FAIL");

    // Count passes and fails
    i = 0;  // reuse as pass counter
    if (regfile_shadow[1]==32'h12345000) i = i + 1;
    if (regfile_shadow[2]==10) i = i + 1;
    if (regfile_shadow[3]==20) i = i + 1;
    if ($signed(regfile_shadow[4])==-5) i = i + 1;
    if (regfile_shadow[5]==30) i = i + 1;
    if (regfile_shadow[6]==10) i = i + 1;
    if (regfile_shadow[10]==1) i = i + 1;
    if (regfile_shadow[11]==0) i = i + 1;
    if (regfile_shadow[15]==99) i = i + 1;
    if (regfile_shadow[16]==2) i = i + 1;
    if (regfile_shadow[17]==32'h00000050) i = i + 1;
    if (regfile_shadow[19]==0) i = i + 1;
    if (regfile_shadow[20]==32'habcde000) i = i + 1;
    if (regfile_shadow[21]==32'h00000000) i = i + 1;
    if (regfile_shadow[22]==32'habcde000) i = i + 1;
    if (regfile_shadow[23]==32'h54322000) i = i + 1;
    if (regfile_shadow[24]==0) i = i + 1;
    if (regfile_shadow[25]==32'h00322000) i = i + 1;
    if (regfile_shadow[26]==32'h00322000) i = i + 1;
    if (regfile_shadow[27]==32'h00322000) i = i + 1;
    if (regfile_shadow[28]==1) i = i + 1;
    if (riscv_inst.data_memory.Memory[addr_index]==32'h54322000) i = i + 1;
    
    $display("\n=== Summary ===");
    $display("Tests Passed: %0d/22", i);
    $display("Tests Failed: %0d/22", 22-i);
    
    if (i == 22) begin
        $display("\n*** ALL TESTS PASSED! ***");
    end else begin
        $display("\n*** SOME TESTS FAILED - CHECK YOUR IMPLEMENTATION ***");
    end

    $finish;
end

initial begin
    #10000;
    $display("\nERROR: Simulation timeout!");
    $finish;
end

endmodule