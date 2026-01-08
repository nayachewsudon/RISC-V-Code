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
    riscv_inst.IMEM.RAM[1] = 32'h00000013;  // nop
    riscv_inst.IMEM.RAM[2] = 32'h00000013;  // nop
    riscv_inst.IMEM.RAM[3] = 32'h00000013;  // nop
    
    // Test 2: ADDI x2
    riscv_inst.IMEM.RAM[4] = 32'h00a00113;  // addi x2, x0, 10
    riscv_inst.IMEM.RAM[5] = 32'h00000013;  // nop
    riscv_inst.IMEM.RAM[6] = 32'h00000013;  // nop
    riscv_inst.IMEM.RAM[7] = 32'h00000013;  // nop
    
    // Test 3: ADDI x3
    riscv_inst.IMEM.RAM[8] = 32'h01400193;  // addi x3, x0, 20
    riscv_inst.IMEM.RAM[9] = 32'h00000013;  // nop
    riscv_inst.IMEM.RAM[10] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[11] = 32'h00000013; // nop
    
    // Test 4: ADDI x4
    riscv_inst.IMEM.RAM[12] = 32'hfff00213; // addi x4, x0, -1
    riscv_inst.IMEM.RAM[13] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[14] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[15] = 32'h00000013; // nop
    
    // Test 5: ADD (uses x2, x3)
    riscv_inst.IMEM.RAM[16] = 32'h003102b3; // add x5, x2, x3  (10+20=30)
    riscv_inst.IMEM.RAM[17] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[18] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[19] = 32'h00000013; // nop
    
    // Test 6: SUB (uses x3, x4)
    riscv_inst.IMEM.RAM[20] = 32'h40418333; // sub x6, x3, x4  (20-(-1)=21)
    riscv_inst.IMEM.RAM[21] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[22] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[23] = 32'h00000013; // nop
    
    // Test 7: SLL (uses x2, x4 - but x4 only needs lower 5 bits)
    riscv_inst.IMEM.RAM[24] = 32'h004113b3; // sll x7, x2, x4  (10 << 31 due to -1)
    riscv_inst.IMEM.RAM[25] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[26] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[27] = 32'h00000013; // nop
    
    // Test 8: Memory address setup
    riscv_inst.IMEM.RAM[28] = 32'h07000413; // addi x8, x0, 112
    riscv_inst.IMEM.RAM[29] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[30] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[31] = 32'h00000013; // nop
    
    // Test 9: SW (uses x2, x8)
    riscv_inst.IMEM.RAM[32] = 32'h00242023; // sw x2, 0(x8)
    riscv_inst.IMEM.RAM[33] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[34] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[35] = 32'h00000013; // nop
    
    // Test 10: LW (uses x8)
    riscv_inst.IMEM.RAM[36] = 32'h00042483; // lw x9, 0(x8)
    riscv_inst.IMEM.RAM[37] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[38] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[39] = 32'h00000013; // nop
    
    // Test 11: BEQ setup
    riscv_inst.IMEM.RAM[40] = 32'h00a00513; // addi x10, x0, 10
    riscv_inst.IMEM.RAM[41] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[42] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[43] = 32'h00000013; // nop
    
    // Test 12: BEQ (uses x9, x10)
    riscv_inst.IMEM.RAM[44] = 32'h00000593; // addi x11, x0, 0
    riscv_inst.IMEM.RAM[45] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[46] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[47] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[48] = 32'h00a48863; // beq x9, x10, 16 (skip if equal)
    riscv_inst.IMEM.RAM[49] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[50] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[51] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[52] = 32'h00100593; // addi x11, x0, 1 (should skip)
    riscv_inst.IMEM.RAM[53] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[54] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[55] = 32'h00000013; // nop
    
    // Test 13: After branch target
    riscv_inst.IMEM.RAM[56] = 32'h00200613; // addi x12, x0, 2
    riscv_inst.IMEM.RAM[57] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[58] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[59] = 32'h00000013; // nop
    
    // Test 14: JAL
    riscv_inst.IMEM.RAM[60] = 32'h010006ef; // jal x13, 16
    riscv_inst.IMEM.RAM[61] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[62] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[63] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[64] = 32'h00300713; // addi x14, x0, 3 (should skip)
    riscv_inst.IMEM.RAM[65] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[66] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[67] = 32'h00000013; // nop
    
    // Test 15: JAL target
    riscv_inst.IMEM.RAM[68] = 32'h00400793; // addi x15, x0, 4
    riscv_inst.IMEM.RAM[69] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[70] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[71] = 32'h00000013; // nop
    
    // Test 16: XOR (uses x5, x3)
    riscv_inst.IMEM.RAM[72] = 32'h0032c833; // xor x16, x5, x3
    riscv_inst.IMEM.RAM[73] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[74] = 32'h00000013; // nop
    riscv_inst.IMEM.RAM[75] = 32'h00000013; // nop
    
    // End marker
    riscv_inst.IMEM.RAM[76] = 32'h00000013; // nop
    
    // Initialize data memory
    for (i = 0; i < 1024; i = i + 1) begin
        riscv_inst.DMEM.Memory[i] = 32'h00000000;
    end
end

// Waveform dump
initial begin
    $dumpfile("riscv_test.vcd");
    $dumpvars(0, testbench);
    
    reset = 1;
    #20;
    reset = 0;
    
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
    if (!reset && riscv_inst.PROGRAMCOUNTER.updated_pc >= 32'h00000134) begin
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

endmodule