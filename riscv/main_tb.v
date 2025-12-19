`timescale 1ns/1ps
`include "main.v"

module testbench;

reg clk;
reg rst;

rv_mc riscv_mc_inst (
    .clk(clk),
    .rst(rst)
);

// ==================================================
// Cycle counting logic
// ==================================================

integer cycle_count;
integer instr_start_cycle;
integer instr_cycles;
reg instr_active;

integer r_type_cycles   = -1;
integer i_type_cycles   = -1;
integer load_cycles     = -1;
integer store_cycles    = -1;
integer branch_cycles   = -1;
integer jal_cycles      = -1;

reg [31:0] last_instr;
reg [2:0] current_type;
reg [3:0] prev_state;

wire [6:0] opcode;
assign opcode = riscv_mc_inst.instr_reg[6:0];

// FSM states (must match your FSM)
localparam FETCH = 0; 
localparam DECODE = 1; 
localparam WB_ALU = 7;
localparam WB_MEM = 4;
localparam MEM_WRITE = 5;
localparam BEQ = 8;

function [2:0] instr_type;
    input [6:0] op;
    begin
        case (op)
            7'b0110011: instr_type = 3'd0; // R-type
            7'b0010011: instr_type = 3'd1; // I-type
            7'b0000011: instr_type = 3'd2; // LOAD
            7'b0100011: instr_type = 3'd3; // STORE
            7'b1100011: instr_type = 3'd4; // BRANCH
            7'b1101111: instr_type = 3'd5; // JAL
            default:    instr_type = 3'd7;
        endcase
    end
endfunction

// ==================================================
// Shadow register file
// ==================================================

reg [31:0] regfile_shadow [0:31];
integer i;
integer addr_index;

// ==================================================
// Clock
// ==================================================

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// ==================================================
// Cycle counter
// ==================================================

always @(posedge clk) begin
    if (!rst)
        cycle_count <= 0;
    else
        cycle_count <= cycle_count + 1;
end

// ==================================================
// Instruction cycle measurement (STATE-BASED)
// ==================================================

always @(posedge clk) begin
    if (!rst) begin
        instr_active      <= 0;
        instr_start_cycle <= 0;
        last_instr        <= 32'b0;
        current_type      <= 3'd7;
        prev_state        <= FETCH;
    end else begin
        prev_state <= riscv_mc_inst.CONTROLLER.fsm.state;

        // Detect transition INTO DECODE state (start of new instruction)
        if (riscv_mc_inst.CONTROLLER.fsm.state == DECODE && 
            prev_state == FETCH &&
            riscv_mc_inst.instr_reg != 32'h00000013 &&
            riscv_mc_inst.instr_reg != 32'b0) begin
            
            // Start counting from the FETCH state (previous cycle)
            instr_active      <= 1;
            instr_start_cycle <= cycle_count - 1;
            last_instr        <= riscv_mc_inst.instr_reg;
            current_type      <= instr_type(opcode);
            
            $display("[Cycle %0d] DECODE: Instruction 0x%h (type %0d) started at cycle %0d", 
                     cycle_count, riscv_mc_inst.instr_reg, instr_type(opcode), cycle_count - 1);
        end

        // Instructions with writeback (R-type, I-type, LOAD, JAL)
        if (instr_active && riscv_mc_inst.we_rf && 
            (riscv_mc_inst.CONTROLLER.fsm.state == WB_ALU || 
             riscv_mc_inst.CONTROLLER.fsm.state == WB_MEM)) begin
            
            instr_cycles = cycle_count - instr_start_cycle + 1;
            
            case (current_type)
                3'd0: if (r_type_cycles == -1) begin
                    r_type_cycles = instr_cycles;
                    $display("[Cycle %0d] R-type completed: %0d cycles", cycle_count, instr_cycles);
                end
                3'd1: if (i_type_cycles == -1) begin
                    i_type_cycles = instr_cycles;
                    $display("[Cycle %0d] I-type completed: %0d cycles", cycle_count, instr_cycles);
                end
                3'd2: if (load_cycles == -1) begin
                    load_cycles = instr_cycles;
                    $display("[Cycle %0d] LOAD completed: %0d cycles", cycle_count, instr_cycles);
                    $display("        LW debug: rd=x%0d, data=0x%h, mem_addr=0x%h", 
                             riscv_mc_inst.instr_reg[11:7],
                             riscv_mc_inst.mux4_output,
                             riscv_mc_inst.alu_output);
                end
                3'd5: if (jal_cycles == -1) begin
                    jal_cycles = instr_cycles;
                    $display("[Cycle %0d] JAL completed: %0d cycles", cycle_count, instr_cycles);
                end
            endcase
            
            instr_active <= 0;
        end

        // STORE instruction (detect we_mem in MEM_WRITE state)
        if (instr_active && current_type == 3'd3 && 
            riscv_mc_inst.we_mem && riscv_mc_inst.CONTROLLER.fsm.state == MEM_WRITE) begin
            
            instr_cycles = cycle_count - instr_start_cycle + 1;
            
            if (store_cycles == -1) begin
                store_cycles = instr_cycles;
                $display("[Cycle %0d] STORE completed: %0d cycles", cycle_count, instr_cycles);
                $display("        SW debug: data=0x%h, mem_addr=0x%h", 
                         riscv_mc_inst.read_data,
                         riscv_mc_inst.alu_output);
            end
            
            instr_active <= 0;
        end

        // BRANCH instruction (completes in BEQ state)
        if (instr_active && current_type == 3'd4 && 
            riscv_mc_inst.CONTROLLER.fsm.state == BEQ) begin
            
            instr_cycles = cycle_count - instr_start_cycle + 1;
            
            if (branch_cycles == -1) begin
                branch_cycles = instr_cycles;
                $display("[Cycle %0d] BRANCH completed: %0d cycles", cycle_count, instr_cycles);
            end
            
            instr_active <= 0;
        end
    end
end

// ==================================================
// Track register writes and memory operations
// ==================================================

always @(posedge clk) begin
    if (riscv_mc_inst.we_rf) begin
        regfile_shadow[riscv_mc_inst.instr_reg[11:7]]
            <= riscv_mc_inst.mux4_output;
        
        // Debug register writes
        if (riscv_mc_inst.instr_reg[11:7] != 0) begin
            $display("        [Cycle %0d] RF Write: x%0d <= 0x%h (sel_result=%b)", 
                     cycle_count,
                     riscv_mc_inst.instr_reg[11:7],
                     riscv_mc_inst.mux4_output,
                     riscv_mc_inst.sel_result);
        end
    end
    
    // Debug memory writes
    if (riscv_mc_inst.we_mem) begin
        $display("        [Cycle %0d] MEM Write: addr=0x%h, data=0x%h", 
                 cycle_count,
                 riscv_mc_inst.mux1_output,
                 riscv_mc_inst.rd2_reg);
    end
    
    // Debug memory reads (when in MEM_RD state)
    if (riscv_mc_inst.CONTROLLER.fsm.state == 3) begin // MEM_RD = 3
        $display("        [Cycle %0d] MEM Read: addr=0x%h, data=0x%h", 
                 cycle_count,
                 riscv_mc_inst.mux1_output,
                 riscv_mc_inst.read_data);
    end
end

// ==================================================
// Initialize memory
// ==================================================

initial begin
    $readmemh("test.hex", riscv_mc_inst.MEM.RAM);
    
    // Pre-initialize memory location 0x70 with test data (for small RAM)
    // Address 0x70 in byte-addressable memory = word address 28
    riscv_mc_inst.MEM.RAM[32'h70 >> 2] = 32'hDEADBEEF;
    
    $display("Pre-initialized memory[0x70] = 0x%h", riscv_mc_inst.MEM.RAM[32'h70 >> 2]);
end

// ==================================================
// Test sequence
// ==================================================

initial begin
    addr_index = 32'h70 >> 2;  // Changed from 0x1000 to 0x70 for small RAM
    
    $dumpfile("riscv_test.vcd");
    $dumpvars(0, riscv_mc_inst);

    rst = 0;
    #20;
    rst = 1;

    for (i = 0; i < 32; i = i + 1)
        regfile_shadow[i] = 0;

    #10000;

$display("x1  (LUI)        = 0x%h  (expect 0x12345000)  | %s", regfile_shadow[1], (regfile_shadow[1]==32'h12345000) ? "OK" : "WRONG");
$display("x2  (ADDI 10)    = %0d   (expect 10)          | %s", regfile_shadow[2], (regfile_shadow[2]==10) ? "OK" : "WRONG");
$display("x3  (ADDI 20)    = %0d   (expect 20)          | %s", regfile_shadow[3], (regfile_shadow[3]==20) ? "OK" : "WRONG");
$display("x4  (ADDI -5)    = %0d   (expect -5)          | %s", $signed(regfile_shadow[4]), ($signed(regfile_shadow[4])==-5) ? "OK" : "WRONG");
$display("x5  (ADD)        = %0d   (expect 30)          | %s", regfile_shadow[5], (regfile_shadow[5]==30) ? "OK" : "WRONG");
$display("x6  (SUB)        = %0d   (expect 10)          | %s", regfile_shadow[6], (regfile_shadow[6]==10) ? "OK" : "WRONG");

// Comparisons
$display("x10 (SLT)        = %0d   (expect 1)           | %s", regfile_shadow[10], (regfile_shadow[10]==1) ? "OK" : "WRONG");
$display("x11 (SLTU)       = %0d   (expect 0)           | %s", regfile_shadow[11], (regfile_shadow[11]==0) ? "OK" : "WRONG");

// Branch and jump
$display("x15 (BEQ flag)   = %0d   (expect 99)          | %s", regfile_shadow[15], (regfile_shadow[15]==99) ? "OK" : "WRONG");
$display("x16 (BEQ taken)  = %0d   (expect 2)           | %s", regfile_shadow[16], (regfile_shadow[16]==2) ? "OK" : "WRONG");

// JAL x17
$display("x17 (JAL link)   = 0x%h  (expect 0x00000050)  | %s", regfile_shadow[17], (regfile_shadow[17]==32'h00000050) ? "OK" : "WRONG");

// After JAL
$display("x19 (after JAL)  = %0d   (expect 0)           | %s", regfile_shadow[19], (regfile_shadow[19]==0) ? "OK" : "WRONG");

// Extended instructions
$display("x20 (new LUI)    = 0x%h  (expect 0xabcde000)  | %s", regfile_shadow[20], (regfile_shadow[20]==32'habcde000) ? "OK" : "WRONG");
$display("x21 (SRA x3>>x2) = 0x%h  (expect 0x00000000)  | %s", regfile_shadow[21], (regfile_shadow[21]==32'h00000000) ? "OK" : "WRONG");
$display("x22 (ADD x20+x21)= 0x%h  (expect 0xabcddeef)  | %s", regfile_shadow[22], (regfile_shadow[22]==32'habcddeef) ? "OK" : "WRONG");
$display("x23 (SUB x21-x22)= 0x%h  (expect 0x00000070)  | %s", regfile_shadow[23], (regfile_shadow[23]==32'h00000070) ? "OK" : "WRONG");
$display("x24 (SLTU)       = %0d   (expect 117443475)    | %s", regfile_shadow[24], (regfile_shadow[24]==32'd117443475) ? "OK" : "WRONG");
$display("x25 (AND x22,x23)= 0x%h  (expect 0x00002000)  | %s", regfile_shadow[25], (regfile_shadow[25]==32'h00002000) ? "OK" : "WRONG");
$display("x26 (OR x24,x25) = 0x%h  (expect 0x00002000)  | %s", regfile_shadow[26], (regfile_shadow[26]==32'h00002000) ? "OK" : "WRONG");
$display("x27 (XOR x26,x21)= 0x%h  (expect 0x00002000)  | %s", regfile_shadow[27], (regfile_shadow[27]==32'h00002000) ? "OK" : "WRONG");
$display("x28 (SLT x27,x22)= %0d   (expect 0)           | %s", regfile_shadow[28], (regfile_shadow[28]==0) ? "OK" : "WRONG");

$display("x22 (before SW)       = 0x%h  (expect 0xabcddeef) | %s", regfile_shadow[22], (regfile_shadow[22]==32'habcddeef) ? "OK" : "WRONG");
$display("Memory at 0x70        = 0x%h  (expect 0x00000070) | %s", riscv_mc_inst.MEM.RAM[addr_index], (riscv_mc_inst.MEM.RAM[addr_index]==32'h00000070) ? "OK" : "WRONG");
$display("x24 (after LW)        = 0x%h  (expect 0x07000b93) | %s", regfile_shadow[24], (regfile_shadow[24]==32'h07000b93) ? "OK" : "WRONG");

    $display("\n=== CYCLES PER INSTRUCTION TYPE ===");
    $display("R-type   : %0d cycles", (r_type_cycles == -1) ? 0 : r_type_cycles);
    $display("I-type   : %0d cycles", (i_type_cycles == -1) ? 0 : i_type_cycles);
    $display("Load     : %0d cycles", (load_cycles == -1) ? 0 : load_cycles);
    $display("Store    : %0d cycles", (store_cycles == -1) ? 0 : store_cycles);
    $display("Branch   : %0d cycles", (branch_cycles == -1) ? 0 : branch_cycles);
    $display("JAL      : %0d cycles", (jal_cycles == -1) ? 0 : jal_cycles);

    $display("\n=== TEST COMPLETE ===");
    $finish;
end

// ==================================================
// Timeout
// ==================================================

initial begin
    #20000;
    $display("ERROR: Simulation timeout!");
    $finish;
end

endmodule