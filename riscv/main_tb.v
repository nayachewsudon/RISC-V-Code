`timescale 1ns/1ps
`include "main.v"

module testbench;

reg clk;
reg reset;

riscv riscv_inst (
    .clk(clk),
    .reset(reset)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//Waveform dump
initial begin
    $dumpfile("riscv_test.vcd");
    $dumpvars(0, testbench);
    
    // Reset sequence
    reset = 1;
    #20;
    reset = 0;
    
    // DEBUG: Check if instructions loaded
    $display("=== Instruction Memory Check ===");
    $display("Memory[0] = 0x%h", riscv_inst.instruction_memory.Memory[0]);
    $display("Memory[1] = 0x%h", riscv_inst.instruction_memory.Memory[1]);
    $display("Memory[2] = 0x%h", riscv_inst.instruction_memory.Memory[2]);
    $display("Memory[3] = 0x%h", riscv_inst.instruction_memory.Memory[3]);

    #2000;
        
    $display("\n=== Final Test Results ===");
    $display("x1 (LUI result) = 0x%h (expect 0x12345000)", riscv_inst.register_file.Registers[1]);
    $display("x2 (ADDI 10) = %d (expect 10)", riscv_inst.register_file.Registers[2]);
    $display("x3 (ADDI 10) = %d (expect 10)", riscv_inst.register_file.Registers[3]);
    $display("x4 (ADDI 5) = %d (expect 5)", riscv_inst.register_file.Registers[4]);
    $display("x5 (ADD 15) = %d (expect 15)", riscv_inst.register_file.Registers[5]);
    $display("x6 (SUB 5) = %d (expect 5)", riscv_inst.register_file.Registers[6]);
    $display("x7 (AND result) = %d", riscv_inst.register_file.Registers[7]);
    $display("x8 (OR result) = %d", riscv_inst.register_file.Registers[8]);
    $display("x9 (LW result) = %d (expect 15)", riscv_inst.register_file.Registers[9]);
    $display("x10 (after BEQ) = %d", riscv_inst.register_file.Registers[10]);
    $display("x11 (JAL return) = 0x%h", riscv_inst.register_file.Registers[11]);
    $display("x12 (after JAL) = %d", riscv_inst.register_file.Registers[12]);

$finish;
end

initial begin
    #10000;
    $display("Timeout");
    $finish;
end

endmodule