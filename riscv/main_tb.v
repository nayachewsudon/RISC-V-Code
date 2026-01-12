`timescale 1ns/1ps
`include "main.v"

module testbench;

reg clk;
reg reset;

rv_pl riscv_inst (
    .clk(clk),
    .rst_n(reset)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// ===== CAPTURED VALUES FOR REUSED REGISTERS =====
// x1: LUI (0x12345000) → ADDI (5)
reg [31:0] x1_lui = 32'h0;
reg [31:0] x1_final = 32'h0;

// x2: ADDI (10) → ADDI (7)
reg [31:0] x2_first = 32'h0;
reg [31:0] x2_final = 32'h0;

// x3: ADDI (20) → ADD (12)
reg [31:0] x3_first = 32'h0;
reg [31:0] x3_final = 32'h0;

// x4: ADDI (-5) → ADD (17)
reg [31:0] x4_first = 32'h0;
reg [31:0] x4_final = 32'h0;

// x5: ADD (30) → SUB (5)
reg [31:0] x5_first = 32'h0;
reg [31:0] x5_final = 32'h0;

// x6: SUB (10) → ADD (22)
reg [31:0] x6_first = 32'h0;
reg [31:0] x6_final = 32'h0;

// x17: JAL (flushed) - only capture if written
reg [31:0] x17_jal = 32'h0;

// x22: ADD → LUI → ADDI → ADDI (BEQ test)
reg [31:0] x22_add = 32'h0;
reg [31:0] x22_lui = 32'h0;
reg [31:0] x22_addi = 32'h0;
reg [31:0] x22_final = 32'h0;

// x23: SUB (flushed) → ADDI (0x70) → ADDI (2)
reg [31:0] x23_sub = 32'h0;
reg [31:0] x23_addr = 32'h0;
reg [31:0] x23_final = 32'h0;

// x24: SLTU → LW (0x70)
reg [31:0] x24_sltu = 32'h0;
reg [31:0] x24_lw_first = 32'h0;

//New ones
reg [31:0] x20_lui = 32'h0;
reg [31:0] x21_sra = 32'h0;
reg [31:0] x10_sll = 32'h0; 
reg [31:0] x11_sltu = 32'h0; 
reg [31:0] x12_xor = 32'h0; 
reg [31:0] x13_srl = 32'h0; 
reg [31:0] x14_or = 32'h0; 

// Write counters for each register
integer x1_writes = 0;
integer x2_writes = 0;
integer x3_writes = 0;
integer x4_writes = 0;
integer x5_writes = 0;
integer x6_writes = 0;
integer x17_writes = 0;
integer x20_writes = 0;
integer x21_writes = 0;
integer x22_writes = 0;
integer x23_writes = 0;
integer x24_writes = 0;
integer x10_writes = 0; 
integer x11_writes = 0; 
integer x12_writes = 0; 
integer x13_writes = 0; 
integer x14_writes = 0; 

// Capture logic - track all writes in order
always @(posedge clk) begin
    if (reset && riscv_inst.PLR4.W_we_rf) begin
        case (riscv_inst.PLR4.W_rf_a3)
            5'd1: begin
                case (x1_writes)
                    0: x1_lui <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                    1: x1_final <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x1_writes <= x1_writes + 1;
            end
            
            5'd2: begin
                case (x2_writes)
                    0: x2_first <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                    1: x2_final <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x2_writes <= x2_writes + 1;
            end
            
            5'd3: begin
                case (x3_writes)
                    0: x3_first <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                    1: x3_final <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x3_writes <= x3_writes + 1;
            end
            
            5'd4: begin
                case (x4_writes)
                    0: x4_first <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                    1: x4_final <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x4_writes <= x4_writes + 1;
            end
            
            5'd5: begin
                case (x5_writes)
                    0: x5_first <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                    1: x5_final <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x5_writes <= x5_writes + 1;
            end
            
            5'd6: begin
                case (x6_writes)
                    0: x6_first <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                    1: x6_final <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x6_writes <= x6_writes + 1;
            end

            5'd10: begin
                case (x10_writes)
                    0: x10_sll <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x10_writes <= x10_writes + 1;
            end

            5'd11: begin
                case (x11_writes)
                    0: x11_sltu <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x11_writes <= x11_writes + 1;
            end

            5'd12: begin
                case (x12_writes)
                    0: x12_xor <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x12_writes <= x12_writes + 1;
            end

            5'd13: begin
                case (x13_writes)
                    0: x13_srl <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x13_writes <= x13_writes + 1;
            end

            5'd14: begin
                case (x14_writes)
                    0: x14_or <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x14_writes <= x10_writes + 1;
            end
            
            5'd17: begin
                x17_jal <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                x17_writes <= x17_writes + 1;
            end
            
            5'd22: begin
                case (x22_writes)
                    0: x22_add <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                    1: x22_lui <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                    2: x22_addi <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                    3: x22_final <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x22_writes <= x22_writes + 1;
            end
            
            5'd23: begin
                case (x23_writes)
                    0: x23_sub <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                    1: x23_addr <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                    2: x23_final <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x23_writes <= x23_writes + 1;
            end
            
            5'd24: begin
                case (x24_writes)
                    0: x24_sltu <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                    1: x24_lw_first <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x24_writes <= x24_writes + 1;
            end
            5'd20: begin
                case (x20_writes)
                    0: x20_lui <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x20_writes <= x20_writes + 1;
            end

            5'd21: begin
                case (x21_writes)
                    0: x21_sra <= riscv_inst.WRITEBACK_MULTIPLEXER.out_m;
                endcase
                x21_writes <= x21_writes + 1;
            end
        endcase
    end
end

// Initialize memory
initial begin
    $readmemh("test.hex", riscv_inst.IMEM.RAM);
    #1
    riscv_inst.DMEM.Memory[32'h70 >> 2] = 32'hDEADBEEF;
end

// Waveform dump
initial begin
    $dumpfile("main_test.vcd");
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
    #15000;
    $display("\nERROR: Simulation timeout!");
    $finish;
end

always @(posedge clk) begin
    if (riscv_inst.PROGRAMCOUNTER.updated_pc >= 32'h00000144) begin
        #30;
        
        $display("\n========================================");
        $display("  RISC-V PIPELINE TEST RESULTS");
        $display("========================================\n");
        
        // ===== BASIC INSTRUCTIONS =====
        $display("=== BASIC INSTRUCTIONS ===");
        $display("x1  (LUI)        = 0x%08h | expect 0x12345000 | %s", 
                 x1_lui, 
                 (x1_lui == 32'h12345000) ? "PASS " : "FAIL ");
        $display("x2  (ADDI 10)    = %10d | expect         10 | %s", 
                 x2_first, 
                 (x2_first == 10) ? "PASS " : "FAIL ");
        $display("x3  (ADDI 20)    = %10d | expect         20 | %s", 
                 x3_first, 
                 (x3_first == 20) ? "PASS " : "FAIL ");
        $display("x4  (ADDI -5)    = %10d | expect         -5 | %s", 
                 $signed(x4_first), 
                 ($signed(x4_first) == -5) ? "PASS " : "FAIL ");
        
        // ===== DATA HAZARDS (FIRST SET) =====
        $display("\n=== DATA HAZARDS (First Set) ===");
        $display("x5  (ADD)        = %10d | expect         30 | %s | [RAW: x2→x5, x3→x5]", 
                 x5_first, 
                 (x5_first == 30) ? "PASS " : "FAIL ");
        $display("x6  (SUB)        = %10d | expect         10 | %s | [RAW: x3→x6, x2→x6]", 
                 x6_first, 
                 (x6_first == 10) ? "PASS " : "FAIL ");
        $display("x7  (ADD)        = %10d | expect         30 | %s", 
                 riscv_inst.RF.Registers[7], 
                 (riscv_inst.RF.Registers[7] == 30) ? "PASS " : "FAIL ");
        $display("x8  (SLT)        = %10d | expect          1 | %s | [Signed comparison]", 
                 riscv_inst.RF.Registers[8], 
                 (riscv_inst.RF.Registers[8] == 1) ? "PASS " : "FAIL ");
        $display("x9  (SUB)        = %10d | expect        -15 | %s | [RAW: x4→x9]", 
                 $signed(riscv_inst.RF.Registers[9]), 
                 ($signed(riscv_inst.RF.Registers[9]) == -15) ? "PASS " : "FAIL ");
        $display("x10 (SLL)        = %10d | expect      10240 | %s", 
                 x10_sll, 
                 (x10_sll == 10240) ? "PASS " : "FAIL ");
        $display("x11 (SLTU)       = %10d | expect          1 | %s", 
                 x11_sltu, 
                 (x11_sltu == 1) ? "PASS " : "FAIL ");
        $display("x12 (XOR)        = 0x%08h | expect 0xFFFFFFEF | %s", 
                 x12_xor, 
                 (x12_xor == 32'hFFFFFFEF) ? "PASS " : "FAIL ");
        $display("x13 (SRL)        = %10d | expect          0 | %s", 
                 x13_srl, 
                 (x13_srl == 0) ? "PASS " : "FAIL ");
        $display("x14 (OR)         = %10d | expect         30 | %s", 
                 x14_or, 
                 (x14_or == 30) ? "PASS " : "FAIL ");
        
        // ===== BRANCH CONTROL HAZARDS =====
        $display("\n=== BRANCH CONTROL HAZARDS ===");
        $display("x15 (BEQ test)   = %10d | expect          1 | %s | [Not taken → execute]", 
                 riscv_inst.RF.Registers[15], 
                 (riscv_inst.RF.Registers[15] == 1) ? "PASS " : "FAIL ");
        $display("x16 (after BEQ)  = %10d | expect          2 | %s | [Taken → skip then exec]", 
                 riscv_inst.RF.Registers[16], 
                 (riscv_inst.RF.Registers[16] == 2) ? "PASS " : "FAIL ");
        $display("x17 (JAL link)   = 0x%08h | expect 0x00000000 | %s | [FLUSHED by later JAL]", 
                 x17_jal, 
                 (x17_jal == 32'h00000000) ? "PASS " : "FAIL ");
        $display("x19 (JAL target) = %10d | expect          0 | %s | [Overwrites skipped instr]", 
                 riscv_inst.RF.Registers[19], 
                 (riscv_inst.RF.Registers[19] == 0) ? "PASS " : "FAIL ");
        
        $display("\n=== EXTENDED INSTRUCTIONS ===");
        $display("x20 (LUI)        = 0x%08h | expect 0xABCDE000 | %s ", 
                x20_lui, 
                (x20_lui == 32'habcde000) ? "PASS " : "FAIL ");

        $display("x21 (SRA)        = 0x%08h | expect 0x00000000 | %s ", 
                x21_sra, 
                (x21_sra == 32'h00000000) ? "PASS " : "FAIL "); 

        $display("x22 (ADD)        = 0x%08h | expect 0xABCDE000 | %s ", 
                x22_add, 
                (x22_add == 32'hABCDE000) ? "PASS " : "FAIL ");

        $display("x23 (SUB)        = 0x%08h | expect 0x54322000 | %s ", 
                x23_sub, 
                (x23_sub == 32'h54322000) ? "PASS " : "FAIL ");

        $display("x24 (SLTU)       = %10d | expect          0 | %s", 
                x24_sltu, 
                (x24_sltu == 0) ? "PASS " : "FAIL ");

        $display("x25 (AND)        = 0x%08h | expect 0x00002000 | %s ", 
                riscv_inst.RF.Registers[25], 
                (riscv_inst.RF.Registers[25] == 32'h00002000) ? "PASS " : "FAIL ");

        $display("x26 (OR)         = 0x%08h | expect 0x00002000 | %s", 
                riscv_inst.RF.Registers[26], 
                (riscv_inst.RF.Registers[26] == 32'h00002000) ? "PASS " : "FAIL ");

        $display("x27 (XOR)        = 0x%08h | expect 0x00002000 | %s ", 
                riscv_inst.RF.Registers[27], 
                (riscv_inst.RF.Registers[27] == 32'h00002000) ? "PASS ✓" : "FAIL ✗");

        $display("x28 (SLT)        = %10d | expect          0 | %s ", 
                riscv_inst.RF.Registers[28], 
                (riscv_inst.RF.Registers[28] == 0) ? "PASS " : "FAIL ");
        
        // ===== MEMORY OPERATIONS (FIRST SET) =====
        $display("\n=== MEMORY OPERATIONS (First Set) ===");
        $display("x22 (LUI)        = 0x%08h | expect 0xDEADB000 | %s", 
                 x22_lui, 
                 (x22_lui == 32'hDEADB000) ? "PASS " : "FAIL ");
        $display("x22 (ADDI)       = 0x%08h | expect 0xDEADAEEF | %s", 
                 x22_addi, 
                 (x22_addi == 32'hDEADAEEF) ? "PASS " : "FAIL ");
        $display("x23 (ADDI addr)  = 0x%08h | expect 0x00000070 | %s", 
                 x23_addr, 
                 (x23_addr == 32'h70) ? "PASS " : "FAIL ");
        $display("Mem[0x70] (SW)   = 0x%08h | expect 0x00000070 | %s", 
                 riscv_inst.DMEM.Memory[32'h70 >> 2], 
                 (riscv_inst.DMEM.Memory[32'h70 >> 2] == 32'h70) ? "PASS " : "FAIL ");
        $display("x24 (LW)         = 0x%08h | expect 0x00000070 | %s | [LOAD-USE: must stall]", 
                 x24_lw_first, 
                 (x24_lw_first == 32'h70) ? "PASS " : "FAIL ");
        
        // ===== NEW DATA HAZARD TESTS =====
        $display("\n=== DATA HAZARD TEST (Chain) ===");
        $display("x1  (ADDI 5)     = %10d | expect          5 | %s | [Overwritten from 0x12345000]", 
                 x1_final, 
                 (x1_final == 5) ? "PASS " : "FAIL ");
        $display("x2  (ADDI 7)     = %10d | expect          7 | %s | [Overwritten from 10]", 
                 x2_final, 
                 (x2_final == 7) ? "PASS " : "FAIL ");
        $display("x3  (ADD)        = %10d | expect         12 | %s | [RAW: x1→x3, x2→x3]", 
                 x3_final, 
                 (x3_final == 12) ? "PASS " : "FAIL ");
        $display("x4  (ADD)        = %10d | expect         17 | %s | [RAW: x3→x4 (forward)]", 
                 x4_final, 
                 (x4_final == 17) ? "PASS " : "FAIL ");
        $display("x5  (SUB)        = %10d | expect          5 | %s | [RAW: x4→x5, x3→x5 (double)]", 
                 x5_final, 
                 (x5_final == 5) ? "PASS " : "FAIL ");
        $display("x6  (ADD)        = %10d | expect         22 | %s | [RAW: x5→x6, x4→x6 (double)]", 
                 x6_final, 
                 (x6_final == 22) ? "PASS " : "FAIL ");
        
        // ===== LOAD-USE HAZARD TEST =====
        $display("\n=== LOAD-USE HAZARD TEST ===");
        $display("x10 (base addr)  = 0x%08h | expect 0x00000080 | %s | [Overwritten from 10240]", 
                 riscv_inst.RF.Registers[10], 
                 (riscv_inst.RF.Registers[10] == 32'h80) ? "PASS " : "FAIL ");
        $display("x11 (test val)   = %10d | expect         42 | %s | [Overwritten from 1]", 
                 riscv_inst.RF.Registers[11], 
                 (riscv_inst.RF.Registers[11] == 42) ? "PASS " : "FAIL ");
        $display("Mem[0x80] (SW)   = 0x%08h | expect 0x0000002A | %s", 
                 riscv_inst.DMEM.Memory[32'h80 >> 2], 
                 (riscv_inst.DMEM.Memory[32'h80 >> 2] == 42) ? "PASS " : "FAIL ");
        $display("x12 (LW)         = %10d | expect         42 | %s | [Overwritten from XOR]", 
                 riscv_inst.RF.Registers[12], 
                 (riscv_inst.RF.Registers[12] == 42) ? "PASS " : "FAIL ");
        $display("x13 (ADD)        = %10d | expect         84 | %s | [LOAD-USE: x12 must stall]", 
                 riscv_inst.RF.Registers[13], 
                 (riscv_inst.RF.Registers[13] == 84) ? "PASS " : "FAIL ");
        $display("x14 (ADD)        = %10d | expect        126 | %s | [Uses forwarded x13]", 
                 riscv_inst.RF.Registers[14], 
                 (riscv_inst.RF.Registers[14] == 126) ? "PASS " : "FAIL ");
        
        // ===== BEQ CONTROL HAZARD TEST =====
        $display("\n=== BEQ CONTROL HAZARD TEST ===");
        $display("x20 (val 10)     = %10d | expect         10 | %s | [Overwritten from LUI]", 
                 riscv_inst.RF.Registers[20], 
                 (riscv_inst.RF.Registers[20] == 10) ? "PASS " : "FAIL ");
        $display("x21 (val 20)     = %10d | expect         20 | %s | [Overwritten from SRA]", 
                 riscv_inst.RF.Registers[21], 
                 (riscv_inst.RF.Registers[21] == 20) ? "PASS " : "FAIL ");
        $display("x22 (BEQ test)   = %10d | expect          1 | %s | [Not taken → exec, Taken → flush ADDI x22, x0, 99]", 
                 x22_final, 
                 (x22_final == 1) ? "PASS " : "FAIL ");
        $display("x23 (after BEQ)  = %10d | expect          2 | %s | [After taken branch]", 
                 x23_final, 
                 (x23_final == 2) ? "PASS " : "FAIL ");
        
        $display("\n========================================");
        $display("         TEST COMPLETE");
        $display("========================================\n");
        
        $finish;
    end
end

endmodule