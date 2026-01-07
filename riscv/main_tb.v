`timescale 1ns/1ps
`include "main.v"

module testbench;

reg clk;
reg reset;
reg [31:0] x22_after_add; 
reg [31:0] x22_after_addi;
reg [31:0] x22_after_lui;
reg [31:0] x23_after_sub; 
reg [31:0] x24_after_sltu;
reg [31:0] x17_after_first_jal;
reg [31:0] x1_after_first_lui;

riscv riscv_inst (
    .clk(clk),
    .rst_n(reset)
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

//Testbench constants
localparam JAL_X17_PC = 32'h00000058;
localparam AFTER_FIRST_LUI_PC = 32'h00000004;
localparam ADD_X22_PC = 32'h00000068;   
localparam SUB_X23_PC = 32'h0000006C;   
localparam SLTU_X24_PC = 32'h00000070; 
localparam LUI_X22_PC = 32'h00000088;  
localparam ADDI_X22_PC = 32'h0000008C;

// Track register writes
always @(posedge clk) begin
    if (!reset) begin
        for (i = 0; i < 32; i = i + 1) begin
            regfile_shadow[i] <= riscv_inst.RF.Registers[i];
        end

        if (riscv_inst.PROGRAMCOUNTER.updated_pc == ADD_X22_PC) begin
            x22_after_add <= riscv_inst.RF.Registers[22];
        end
        if (riscv_inst.PROGRAMCOUNTER.updated_pc == ADDI_X22_PC) begin
            x22_after_addi <= riscv_inst.RF.Registers[22];
        end
        if (riscv_inst.PROGRAMCOUNTER.updated_pc == LUI_X22_PC) begin
            x22_after_lui <= riscv_inst.RF.Registers[22];
        end
        if (riscv_inst.PROGRAMCOUNTER.updated_pc == SUB_X23_PC) begin
            x23_after_sub <= riscv_inst.RF.Registers[23];
        end
        if (riscv_inst.PROGRAMCOUNTER.updated_pc == SLTU_X24_PC) begin 
            x24_after_sltu <= riscv_inst.RF.Registers[24]; 
        end
         if (riscv_inst.PROGRAMCOUNTER.updated_pc == JAL_X17_PC) begin
            x17_after_first_jal <= riscv_inst.RF.Registers[17];
        end
        if (riscv_inst.PROGRAMCOUNTER.updated_pc == AFTER_FIRST_LUI_PC) begin
            x1_after_first_lui <= riscv_inst.RF.Registers[1];
        end
    end
end

// Initialize memory with test.hex
initial begin
    $readmemh("test.hex", riscv_inst.IMEM.RAM);
    
    // Pre-initialize data memory location 0x70 if needed
    // Adjust based on your data memory implementation
    #1
    riscv_inst.DMEM.Memory[32'h70 >> 2] = 32'hDEADBEEF;
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
    $display("Memory[0] = 0x%h (expect 0x123450b7)", riscv_inst.IMEM.RAM[0]);
    $display("Memory[1] = 0x%h (expect 0x00a00113)", riscv_inst.IMEM.RAM[1]);
    $display("Memory[2] = 0x%h (expect 0x01400193)", riscv_inst.IMEM.RAM[2]);
    $display("Memory[3] = 0x%h (expect 0xffb00213)", riscv_inst.IMEM.RAM[3]);
        
end

initial begin
    #10000;
    $display("\nERROR: Simulation timeout!");
    $finish;
end

always @(posedge clk) begin
    if (riscv_inst.PROGRAMCOUNTER.updated_pc >= 32'h0000009C) begin
        #10; 
        
        for (i = 0; i < 32; i = i + 1) begin
            regfile_shadow[i] = riscv_inst.RF.Registers[i];
        end
        
        addr_index = 32'h70 >> 2;

        // Print test results
        $display("\n=== Final Test Results ===");
        $display("=== Basic Instructions ===");
        $display("x1  (LUI)        = 0x%h  (expect 0x12345000)  | %s", x1_after_first_lui, (x1_after_first_lui==32'h12345000) ? "PASS" : "FAIL");
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
        $display("x17 (JAL link)   = 0x%h  (expect 0x00000050)  | %s", x17_after_first_jal, (x17_after_first_jal==32'h00000050) ? "PASS" : "FAIL");
        $display("x19 (after JAL)  = %0d   (expect 0)           | %s", regfile_shadow[19], (regfile_shadow[19]==0) ? "PASS" : "FAIL");
        
        $display("\n=== Extended Instructions ===");
        $display("x20 (LUI)        = 0x%h  (expect 0xabcde000)  | %s", regfile_shadow[20], (regfile_shadow[20]==32'habcde000) ? "PASS" : "FAIL");
        $display("x21 (SRA)        = 0x%h  (expect 0x00000000)  | %s", regfile_shadow[21], (regfile_shadow[21]==32'h00000000) ? "PASS" : "FAIL");
        $display("x22 (ADD)        = 0x%h  (expect 0xabcde000)  | %s", x22_after_add, (x22_after_add==32'habcde000) ? "PASS" : "FAIL");
        $display("x23 (SUB)        = 0x%h  (expect 0x54322000)  | %s", x23_after_sub, (x23_after_sub==32'h54322000) ? "PASS" : "FAIL");
        $display("x24 (SLTU)       = %0d   (expect 0)           | %s", x24_after_sltu, (x24_after_sltu==0) ? "PASS" : "FAIL");
        $display("x25 (AND)        = 0x%h  (expect 0x00002000)  | %s", regfile_shadow[25], (regfile_shadow[25]==32'h00002000) ? "PASS" : "FAIL");
        $display("x26 (OR)         = 0x%h  (expect 0x00002000)  | %s", regfile_shadow[26], (regfile_shadow[26]==32'h00002000) ? "PASS" : "FAIL");
        $display("x27 (XOR)        = 0x%h  (expect 0x00002000)  | %s", regfile_shadow[27], (regfile_shadow[27]==32'h00002000) ? "PASS" : "FAIL");
        $display("x28 (SLT)        = %0d   (expect 0)           | %s", regfile_shadow[28], (regfile_shadow[28]==0) ? "PASS" : "FAIL");
        
        $display("\n=== Memory Operations ===");
        $display("x22 (LUI)        = %0h   (expect 0xdeadb000)           | %s", x22_after_lui, (x22_after_lui==32'hdeadb000) ? "PASS" : "FAIL");
        $display("x22 (ADDI x22, x22, -273)        = %0h   (expect 0xdeadaeef)           | %s", x22_after_addi, (x22_after_addi==32'hdeadaeef) ? "PASS" : "FAIL");
        $display("x23 (ADDI x23, x0, 0x70)        = %0h   (expect 0x70)           | %s", regfile_shadow[23], (regfile_shadow[23]==32'h70) ? "PASS" : "FAIL");
        $display("Memory[0x70] after SW            = 0x%0h   | %s",
            riscv_inst.DMEM.Memory[addr_index],
            (riscv_inst.DMEM.Memory[addr_index] == 32'h70) ? "PASS" : "FAIL");
        $display("x24 (LW 0(x23))                  = 0x%0h   | %s",
            regfile_shadow[24],
            (regfile_shadow[24] == 32'h70) ? "PASS" : "FAIL");

    
    $finish;
    end
end


initial begin
    $monitor("PC=%h, sel_pc=%b, branch=%b, zero_flag=%b, sel_jump=%b, pc_p_imm=%h, pc_p4=%h, se_out=%h, sel_alu_src_a = %b, sel_alu_src_b = %b", 
          riscv_inst.PROGRAMCOUNTER.updated_pc, riscv_inst.BRANCH_JUMP_MULTIPLEXER.sel, riscv_inst.STAGEONE_CONTROLLER.branch, riscv_inst.ALU.zero_flag, 
          riscv_inst.STAGEONE_CONTROLLER.sel_jump, riscv_inst.PC_IMM_ADDER.sum, riscv_inst.ADDER.pc_plus_4, riscv_inst.STAGEONE_CONTROLLER.sel_alu_src_a, riscv_inst.STAGEONE_CONTROLLER.sel_alu_src_b, 
          riscv_inst.SE_RD2_MUX.out_m);

end

endmodule