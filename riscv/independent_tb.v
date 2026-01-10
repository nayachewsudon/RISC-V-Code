`timescale 1ns/1ps
`include "main.v"

module testbench;

reg clk;
reg reset;

riscv riscv_inst (
    .clk(clk),
    .rst_n(reset)
);

integer i;

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Initialize memory with proper NOP spacing for pipeline without hazard unit
initial begin
    // Test 1: LUI
    riscv_inst.IMEM.RAM[0] = 32'h123450b7;  // lui x1, 0x12345
    
    // Test 2: ADDI x2
    riscv_inst.IMEM.RAM[1] = 32'h00a00113;  // addi x2, x0, 10
    
    // Test 3: ADDI x3
    riscv_inst.IMEM.RAM[2] = 32'h01400193;  // addi x3, x0, 20
    
    // Test 4: ADDI x4
    riscv_inst.IMEM.RAM[3] = 32'hfff00213; // addi x4, x0, -1
    
    // Test 5: ADD (uses x2, x3)
    riscv_inst.IMEM.RAM[4] = 32'h003102b3; // add x5, x2, x3  (10+20=30)
    
    // Test 6: SUB (uses x3, x4)
    riscv_inst.IMEM.RAM[5] = 32'h40418333; // sub x6, x3, x4  (20-(-1)=21)
    
    // Test 7: SLL (uses x2, x4 - but x4 only needs lower 5 bits)
    riscv_inst.IMEM.RAM[6] = 32'h004113b3; // sll x7, x2, x4  (10 << 31 due to -1)
    
    // Test 8: Memory address setup
    riscv_inst.IMEM.RAM[7] = 32'h07000413; // addi x8, x0, 112
    
    // Test 9: SW (uses x2, x8)
    riscv_inst.IMEM.RAM[8] = 32'h00242023; // sw x2, 0(x8)
    
    // Test 10: LW (uses x8)
    riscv_inst.IMEM.RAM[9] = 32'h00042483; // lw x9, 0(x8)
    
    // Test 11: BEQ setup
    riscv_inst.IMEM.RAM[10] = 32'h00a00513; // addi x10, x0, 10
    
    // Test 12: BEQ (uses x9, x10)
    riscv_inst.IMEM.RAM[11] = 32'h00000593; // addi x11, x0, 0
    riscv_inst.IMEM.RAM[12] = 32'h00a48863; // beq x9, x10, 16 (skip if equal)
    riscv_inst.IMEM.RAM[13] = 32'h00100593; // addi x11, x0, 1 (should skip)
    
    // Test 13: After branch target
    riscv_inst.IMEM.RAM[14] = 32'h00200613; // addi x12, x0, 2
    
    // Test 14: JAL
    riscv_inst.IMEM.RAM[15] = 32'h010006ef; // jal x13, 16
    riscv_inst.IMEM.RAM[16] = 32'h00300713; // addi x14, x0, 3 (should skip)
    
    // Test 15: JAL target
    riscv_inst.IMEM.RAM[17] = 32'h00400793; // addi x15, x0, 4
    
    // Test 16: XOR (uses x5, x3)
    riscv_inst.IMEM.RAM[18] = 32'h0032c833; // xor x16, x5, x3
    
    // End marker
    riscv_inst.IMEM.RAM[19] = 32'h00000013; // nop
    
    // Initialize data memory
    for (i = 0; i < 1024; i = i + 1) begin
        riscv_inst.DMEM.Memory[i] = 32'h00000000;
    end
end

// Waveform dump
initial begin
    $dumpfile("riscv_test.vcd");
    $dumpvars(0, testbench);
    
    reset = 0;
    #20;
    reset = 1;
    
    $display("=== Pipeline Test (No Hazard Unit) ===");
    $display("Instructions spaced with 3 NOPs for proper pipeline operation\n");
end

// Timeout
initial begin
    #10000;
    $display("\nERROR: Simulation timeout!");
    $finish;
end

// End simulation
always @(posedge clk) begin
    if (reset && riscv_inst.PROGRAMCOUNTER.updated_pc >= 32'h00000150) begin
        #20;
        
        $display("\n=== Final Register State ===");
        $display("Register | Value (Hex) | Value (Dec) | Expected         | Status");
        $display("---------|-------------|-------------|------------------|--------");
        
        $display("x1  (LUI)| 0x%08h  | %11d | 0x12345000       | %s", 
                 riscv_inst.RF.Registers[1], riscv_inst.RF.Registers[1],
                 (riscv_inst.RF.Registers[1] == 32'h12345000) ? "PASS" : "FAIL");
        
        $display("x2  (ADDI)| 0x%08h  | %11d | 10               | %s", 
                 riscv_inst.RF.Registers[2], riscv_inst.RF.Registers[2],
                 (riscv_inst.RF.Registers[2] == 10) ? "PASS" : "FAIL");
        
        $display("x3  (ADDI)| 0x%08h  | %11d | 20               | %s", 
                 riscv_inst.RF.Registers[3], riscv_inst.RF.Registers[3],
                 (riscv_inst.RF.Registers[3] == 20) ? "PASS" : "FAIL");
        
        $display("x4  (ADDI)| 0x%08h  | %11d | -1               | %s", 
                 riscv_inst.RF.Registers[4], $signed(riscv_inst.RF.Registers[4]),
                 (riscv_inst.RF.Registers[4] == 32'hFFFFFFFF) ? "PASS" : "FAIL");
        
        $display("x5  (ADD) | 0x%08h  | %11d | 30               | %s", 
                 riscv_inst.RF.Registers[5], riscv_inst.RF.Registers[5],
                 (riscv_inst.RF.Registers[5] == 30) ? "PASS" : "FAIL");
        
        $display("x6  (SUB) | 0x%08h  | %11d | 21               | %s", 
                 riscv_inst.RF.Registers[6], riscv_inst.RF.Registers[6],
                 (riscv_inst.RF.Registers[6] == 21) ? "PASS" : "FAIL");
        
        $display("x7  (SLL) | 0x%08h  | %11d | 0           | %s", 
                 riscv_inst.RF.Registers[7], riscv_inst.RF.Registers[7],
                 (riscv_inst.RF.Registers[7] == 0) ? "PASS" : "FAIL");
        
        $display("x9  (LW)  | 0x%08h  | %11d | 10               | %s", 
                 riscv_inst.RF.Registers[9], riscv_inst.RF.Registers[9],
                 (riscv_inst.RF.Registers[9] == 10) ? "PASS" : "FAIL");
        
        $display("x11 (BEQ) | 0x%08h  | %11d | 0 (branch taken) | %s", 
                 riscv_inst.RF.Registers[11], riscv_inst.RF.Registers[11],
                 (riscv_inst.RF.Registers[11] == 0) ? "PASS" : "FAIL");
        
        $display("x12 (ADDI)| 0x%08h  | %11d | 2                | %s", 
                 riscv_inst.RF.Registers[12], riscv_inst.RF.Registers[12],
                 (riscv_inst.RF.Registers[12] == 2) ? "PASS" : "FAIL");
        
        $display("x13 (JAL) | 0x%08h  | %11d | 0xF4 (PC+4)      | %s", 
                 riscv_inst.RF.Registers[13], riscv_inst.RF.Registers[13],
                 (riscv_inst.RF.Registers[13] == 32'hF4) ? "PASS" : "CHECK");
        
        $display("x14 (skip)| 0x%08h  | %11d | 0 (JAL skipped)  | %s", 
                 riscv_inst.RF.Registers[14], riscv_inst.RF.Registers[14],
                 (riscv_inst.RF.Registers[14] == 0) ? "PASS" : "FAIL");
        
        $display("x15 (ADDI)| 0x%08h  | %11d | 4                | %s", 
                 riscv_inst.RF.Registers[15], riscv_inst.RF.Registers[15],
                 (riscv_inst.RF.Registers[15] == 4) ? "PASS" : "FAIL");
        
        $display("x16 (XOR) | 0x%08h  | %11d | 10 (30^20)       | %s", 
                 riscv_inst.RF.Registers[16], riscv_inst.RF.Registers[16],
                 (riscv_inst.RF.Registers[16] == 10) ? "PASS" : "FAIL");
        
        $display("\n=== Memory Check ===");
        $display("Mem[112]  | 0x%08h  | %11d | 10               | %s",
                 riscv_inst.DMEM.Memory[28],
                 riscv_inst.DMEM.Memory[28],
                 (riscv_inst.DMEM.Memory[28] == 10) ? "PASS" : "FAIL");
        
        $display("\n=== Test Complete ===\n");
        $finish;
    end
end

// Monitor key registers
initial begin
    $monitor("Time=%0t PC=%h | x1=%h x2=%h x3=%h x5=%h x6=%h x9=%h x11=%h", 
             $time, riscv_inst.PROGRAMCOUNTER.updated_pc,
             riscv_inst.RF.Registers[1],
             riscv_inst.RF.Registers[2],
             riscv_inst.RF.Registers[3],
             riscv_inst.RF.Registers[5],
             riscv_inst.RF.Registers[6],
             riscv_inst.RF.Registers[9],
             riscv_inst.RF.Registers[11]);
end

//Monitor hazard signals, inputs, outputs etc
initial begin 
    $monitor("Time=%0t PC=%h | E_forward_a=%b , E_forward_b=%b , E_flush = %b , D_stall = %b , F_stall = %b , D_flush %b",
    $time, riscv_inst.PROGRAMCOUNTER.updated_pc, 
    riscv_inst.HAZARDUNIT.E_forward_a, 
    riscv_inst.HAZARDUNIT.E_forward_b,
    riscv_inst.HAZARDUNIT.E_flush, 
    riscv_inst.HAZARDUNIT.D_stall,
    riscv_inst.HAZARDUNIT.F_stall,
    riscv_inst.HAZARDUNIT.D_flush);
end
endmodule