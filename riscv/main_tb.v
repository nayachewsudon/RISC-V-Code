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

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
reg x1_captured = 0;
reg x17_captured = 0;
reg x23_captured = 0;
reg x24_captured = 0;
integer x22_writes = 2'd0; 

always @(posedge clk) begin
    if (!reset) begin
        if (riscv_inst.PLR4.W_we_rf && riscv_inst.PLR4.W_rf_a3 == 5'd1 && !x1_captured) begin
            x1_after_first_lui <= riscv_inst.RF.Registers[1];
            x1_captured <= 1;
        end
        
        if (riscv_inst.PLR4.W_we_rf && riscv_inst.PLR4.W_rf_a3 == 5'd17 && !x17_captured) begin
            x17_after_first_jal <= riscv_inst.RF.Registers[17];
            x17_captured <= 1;
        end
        if (riscv_inst.PLR4.W_we_rf && riscv_inst.PLR4.W_rf_a3 == 5'd23 && !x23_captured) begin
            x23_after_sub <= riscv_inst.RF.Registers[23];
            x23_captured <= 1;
        end
        
        if (riscv_inst.PLR4.W_we_rf && riscv_inst.PLR4.W_rf_a3 == 5'd24 && !x24_captured) begin
            x24_after_sltu <= riscv_inst.RF.Registers[24];
            x24_captured <= 1;
        end
        
        if (riscv_inst.PLR4.W_we_rf && riscv_inst.PLR4.W_rf_a3 == 5'd22) begin
            case (x22_writes)
                0: x22_after_add  <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                1: x22_after_lui  <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                2: x22_after_addi <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
            endcase
            x22_writes <= x22_writes + 2'd1;
        end
        
    end
end

// Initialize memory with test.hex
initial begin
    $readmemh("test.hex", riscv_inst.IMEM.RAM);
    
    // Pre-initialize data memory location 0x70 if needed
    #1
    riscv_inst.DMEM.Memory[32'h70 >> 2] = 32'hDEADBEEF;
end

// Waveform dump
initial begin
    $dumpfile("riscv_test.vcd");
    $dumpvars(0, testbench);
    
    // Reset sequence
    reset = 0;
    #20;
    reset = 1;
    
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
        #30; 

        // Print test results
        $display("\n=== Final Test Results ===");
        $display("=== Basic Instructions ===");
        $display("x1  (LUI)        = 0x%h  (expect 0x12345000)  | %s", x1_after_first_lui, (x1_after_first_lui==32'h12345000) ? "PASS" : "FAIL");
        $display("x2  (ADDI 10)    = %0d   (expect 10)          | %s", riscv_inst.RF.Registers[2], (riscv_inst.RF.Registers[2]==10) ? "PASS" : "FAIL");
        $display("x3  (ADDI 20)    = %0d   (expect 20)          | %s", riscv_inst.RF.Registers[3], (riscv_inst.RF.Registers[3]==20) ? "PASS" : "FAIL");
        $display("x4  (ADDI -5)    = %0d   (expect -5)          | %s", $signed(riscv_inst.RF.Registers[4]), ($signed(riscv_inst.RF.Registers[4])==-5) ? "PASS" : "FAIL");

        $display("\n=== Data Hazard ===");
        $display("x5  (ADD)        = %0d   (expect 30)          | %s", riscv_inst.RF.Registers[5], (riscv_inst.RF.Registers[5]==30) ? "PASS" : "FAIL");
        $display("x6  (SUB)        = %0d   (expect 10)          | %s", riscv_inst.RF.Registers[6], (riscv_inst.RF.Registers[6]==10) ? "PASS" : "FAIL");
        $display("x7  (ADD)        = %0d   (expect 30)          | %s", riscv_inst.RF.Registers[7], (riscv_inst.RF.Registers[7]==30) ? "PASS" : "FAIL");
        $display("x8  (SLT)        = %0d   (expect 1; signed operation)          | %s", riscv_inst.RF.Registers[8], (riscv_inst.RF.Registers[8]==1) ? "PASS" : "FAIL");
        $display("x9  (SUB)        = %0d   (expect -15)          | %s", $signed(riscv_inst.RF.Registers[9]), ($signed(riscv_inst.RF.Registers[9])==-15) ? "PASS" : "FAIL");
        $display("x10 (SLL)        = %0d   (expect 10240)           | %s", riscv_inst.RF.Registers[10], (riscv_inst.RF.Registers[10]==10240) ? "PASS" : "FAIL");
        
        $display("x11 (SLTU)       = %0d   (expect 1)           | %s", riscv_inst.RF.Registers[11], (riscv_inst.RF.Registers[11]==1) ? "PASS" : "FAIL");
        $display("x12 (XOR)       = %0h   (expect 0xFFFFFFEF)           | %s", riscv_inst.RF.Registers[12], (riscv_inst.RF.Registers[12]==32'hFFFFFFEF) ? "PASS" : "FAIL");
        $display("x13 (SRL)       = %0d   (expect 0)           | %s", riscv_inst.RF.Registers[13], (riscv_inst.RF.Registers[13]==0) ? "PASS" : "FAIL");
        $display("x14 (OR)       = %0d   (expect 30)           | %s", riscv_inst.RF.Registers[14], (riscv_inst.RF.Registers[14]==30) ? "PASS" : "FAIL");    

        $display("\n=== BRANCH CONTROL HAZARD ===");
        $display("x15 (BEQ flag)   = %0d   (expect 1)          | %s", riscv_inst.RF.Registers[15], (riscv_inst.RF.Registers[15]==1) ? "PASS" : "FAIL");
        $display("x16 (BEQ taken)  = %0d   (expect 2)           | %s", riscv_inst.RF.Registers[16], (riscv_inst.RF.Registers[16]==2) ? "PASS" : "FAIL");
         $display("x17 (JAL link)   = 0x%h  (expect 0x00000050)  | %s", x17_after_first_jal, (x17_after_first_jal==32'h00000050) ? "PASS" : "FAIL");
        $display("x19 (after JAL)  = %0d   (expect 0)           | %s", riscv_inst.RF.Registers[19], (riscv_inst.RF.Registers[19]==0) ? "PASS" : "FAIL");
        
        $display("\n=== Extended Instructions ===");
        $display("x20 (LUI)        = 0x%h  (expect 0xabcde000)  | %s", riscv_inst.RF.Registers[20], (riscv_inst.RF.Registers[20]==32'habcde000) ? "PASS" : "FAIL");
        $display("x21 (SRA)        = 0x%h  (expect 0x00000000)  | %s", riscv_inst.RF.Registers[21], (riscv_inst.RF.Registers[21]==32'h00000000) ? "PASS" : "FAIL");
         $display("x22 (ADD)        = 0x%h  (expect 0xabcde000)  | %s", x22_after_add, (x22_after_add==32'habcde000) ? "PASS" : "FAIL");
        $display("x23 (SUB)        = 0x%h  (expect 0x54322000)  | %s", x23_after_sub, (x23_after_sub==32'h54322000) ? "PASS" : "FAIL");
        $display("x24 (SLTU)       = %0d   (expect 0)           | %s", x24_after_sltu, (x24_after_sltu==0) ? "PASS" : "FAIL");
        $display("x25 (AND)        = 0x%h  (expect 0x00002000)  | %s", riscv_inst.RF.Registers[25], (riscv_inst.RF.Registers[25]==32'h00002000) ? "PASS" : "FAIL");
        $display("x26 (OR)         = 0x%h  (expect 0x00002000)  | %s", riscv_inst.RF.Registers[26], (riscv_inst.RF.Registers[26]==32'h00002000) ? "PASS" : "FAIL");
        $display("x27 (XOR)        = 0x%h  (expect 0x00002000)  | %s", riscv_inst.RF.Registers[27], (riscv_inst.RF.Registers[27]==32'h00002000) ? "PASS" : "FAIL");
        $display("x28 (SLT)        = %0d   (expect 0)           | %s", riscv_inst.RF.Registers[28], (riscv_inst.RF.Registers[28]==0) ? "PASS" : "FAIL");
        
        $display("\n=== LOAD USE HAZARD ===");
        $display("x23 (ADDI x23, x0, 0x70)        = 0x%h   (expect 0x70)           | %s", riscv_inst.RF.Registers[23], (riscv_inst.RF.Registers[23]==32'h70) ? "PASS" : "FAIL");
        $display("Memory[0x70] after SW            = 0x%0h   (expect 0x70) | %s",
            riscv_inst.DMEM.Memory[32'h70 >> 2],
            (riscv_inst.DMEM.Memory[32'h70 >> 2] == 32'h70) ? "PASS" : "FAIL");
        $display("x24 (LW 0(x23))                  = 0x%0h   (expect 0x70) | %s",
            riscv_inst.RF.Registers[24],
            (riscv_inst.RF.Registers[24] == 32'h70) ? "PASS" : "FAIL");

        $finish;
    end
end

initial begin
    $monitor("PC=%h, sel_pc=%b, branch=%b, zero_flag=%b, sel_jump=%b, pc_p_imm=%h, pc_p4=%h, se_out=%h, sel_alu_src_a = %b, sel_alu_src_b = %b, SE_RD_MUX.out = %h", 
          riscv_inst.PROGRAMCOUNTER.updated_pc, riscv_inst.BRANCH_JUMP_MULTIPLEXER.sel, riscv_inst.STAGEONE_CONTROLLER.branch, riscv_inst.ALU.zero_flag, 
          riscv_inst.STAGEONE_CONTROLLER.sel_jump, riscv_inst.PC_IMM_ADDER.sum, riscv_inst.ADDER.pc_plus_4, riscv_inst.SIGNEXTENDER.out, riscv_inst.STAGEONE_CONTROLLER.sel_alu_src_a, riscv_inst.STAGEONE_CONTROLLER.sel_alu_src_b, 
          riscv_inst.SE_RD2_MUX.out_m);
end

//Monitor hazard signals, inputs, outputs etc
initial begin 
    $monitor("Time=%0t PC=%h | E_forward_a=%b , E_forward_b=%b , E_flush = %b , D_stall = %b , F_stall = %b , D_flush %b, M_we_rf=%b, W_we_rf=%b, M_rd=%d, W_rd=%d, E_rs1=%d, E_rs2=%d",
    $time, riscv_inst.PROGRAMCOUNTER.updated_pc, 
    riscv_inst.HAZARDUNIT.E_forward_a, 
    riscv_inst.HAZARDUNIT.E_forward_b,
    riscv_inst.HAZARDUNIT.E_flush, 
    riscv_inst.HAZARDUNIT.D_stall,
    riscv_inst.HAZARDUNIT.F_stall,
    riscv_inst.HAZARDUNIT.D_flush,
    riscv_inst.M_we_rf,
    riscv_inst.W_we_rf,
         riscv_inst.M_rf_a3,
         riscv_inst.W_rf_a3,
         riscv_inst.E_rs1,
         riscv_inst.E_rs2);
end

endmodule