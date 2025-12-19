`timescale 1ns/1ps
`include "controller.v"

module controller_tb ();

// Testbench signals
reg clk;
reg reset_n;
reg zero;
reg [6:0] op;
reg [2:0] funct3;
reg funct7;

// Outputs
wire [1:0] sel_result;
wire [1:0] sel_alu_src_b;
wire [1:0] sel_alu_src_a;
wire sel_mem_addr;
wire we_mem;
wire we_ir;
wire we_rf;
wire [3:0] alu_control;
wire [2:0] sel_ext;
wire we_pc;

// Instantiate the controller
controller dut (
    .clk(clk),
    .reset_n(reset_n),
    .zero(zero),
    .op(op),
    .funct3(funct3),
    .funct7(funct7),
    .sel_result(sel_result),
    .sel_alu_src_b(sel_alu_src_b),
    .sel_alu_src_a(sel_alu_src_a),
    .sel_mem_addr(sel_mem_addr),
    .we_mem(we_mem),
    .we_ir(we_ir),
    .we_rf(we_rf),
    .alu_control(alu_control),
    .sel_ext(sel_ext),
    .we_pc(we_pc)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    $dumpfile("controller_tb.vcd");
    $dumpvars(0, controller_tb);
    
    // Initialize signals
    reset_n = 0;
    zero = 0;
    op = 7'b0000000;
    funct3 = 3'b000;
    funct7 = 0;
    
    //Reset
    #15;
    reset_n = 1;
    #10;
    
    $display("=== Starting Controller Testbench ===\n");
    
    // Test 1: R-type (ADD)
    $display("Test 1: R-type instruction (ADD)");
    op = 7'b0110011;  // R-type opcode
    funct3 = 3'b000;  // ADD
    funct7 = 0;       // ADD (not SUB)
    zero = 0;
    run_instruction_cycle("R-type ADD");
    
    // Test 2: R-type (SUB)
    $display("\nTest 2: R-type instruction (SUB)");
    op = 7'b0110011;  // R-type opcode
    funct3 = 3'b000;  // SUB
    funct7 = 1;       // SUB
    zero = 0;
    run_instruction_cycle("R-type SUB");
    
    // Test 3: I-type (ADDI)
    $display("\nTest 3: I-type instruction (ADDI)");
    op = 7'b0010011;  // I-type ALU opcode
    funct3 = 3'b000;  // ADDI
    funct7 = 0;
    zero = 0;
    run_instruction_cycle("I-type ADDI");
    
    // Test 4: Load instruction (LW)
    $display("\nTest 4: Load instruction (LW)");
    op = 7'b0000011;  // Load opcode
    funct3 = 3'b010;  // LW
    funct7 = 0;
    zero = 0;
    run_instruction_cycle("Load LW");
    
    // Test 5: Store instruction (SW)
    $display("\nTest 5: Store instruction (SW)");
    op = 7'b0100011;  // Store opcode
    funct3 = 3'b010;  // SW
    funct7 = 0;
    zero = 0;
    run_instruction_cycle("Store SW");
    
    // Test 6: Branch instruction (BEQ) - not taken
    $display("\nTest 6: Branch instruction (BEQ) - branch not taken");
    op = 7'b1100011;  // Branch opcode
    funct3 = 3'b000;  // BEQ
    funct7 = 0;
    zero = 0;         // Branch not taken
    run_instruction_cycle("Branch BEQ (not taken)");
    
    // Test 7: Branch instruction (BEQ) - taken
    $display("\nTest 7: Branch instruction (BEQ) - branch taken");
    op = 7'b1100011;  // Branch opcode
    funct3 = 3'b000;  // BEQ
    funct7 = 0;
    zero = 1;         // Branch taken
    run_instruction_cycle("Branch BEQ (taken)");
    
    // Test 8: JAL instruction
    $display("\nTest 8: JAL instruction");
    op = 7'b1101111;  // JAL opcode
    funct3 = 3'b000;
    funct7 = 0;
    zero = 0;
    run_instruction_cycle("JAL");
    
    // Test 9: LUI instruction
    $display("\nTest 9: LUI instruction");
    op = 7'b0110111;  // LUI opcode
    funct3 = 3'b000;
    funct7 = 0;
    zero = 0;
    run_instruction_cycle("LUI");
    
    $display("\n=== Testbench Complete ===");
    #50;
    $finish;
end

// Task to run a complete instruction cycle and monitor outputs
task run_instruction_cycle;
    input [200*8:1] instr_name;
    integer cycle;
    begin
        cycle = 0;
        $display("  Executing: %s", instr_name);
        
        // Monitor for several clock cycles to observe state transitions
        repeat(10) begin
            @(posedge clk);
            cycle = cycle + 1;
            #1;
            
            $display("    Cycle %0d: State=%b, we_pc=%b, we_ir=%b, we_rf=%b, we_mem=%b, sel_result=%b, alu_ctrl=%b",
                     cycle, dut.state, we_pc, we_ir, we_rf, we_mem, sel_result, alu_control);
            
            if (cycle > 1 && dut.state == 4'b0000) begin
                $display("    -> Instruction complete, returned to FETCH state\n");
                cycle = 10; // Exit early
            end
        end
    end
endtask

// Monitor for unexpected conditions
always @(posedge clk) begin
    if (reset_n) begin
        // Check for invalid control signal combinations
        if (we_mem && we_rf) begin
            $display("WARNING: Both we_mem and we_rf asserted at time %0t", $time);
        end
    end
end

endmodule