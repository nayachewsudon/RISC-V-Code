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

// Clock generation
initial clk = 0;
always #5 clk = ~clk;

// Dummy registers to monitor writes
reg [31:0] pc_monitor;
reg [31:0] instr_monitor;
reg [31:0] rf_monitor [0:31];  // simulate register file writes
reg [31:0] mem_monitor [0:31]; // simulate memory writes
integer i;

// Initialize monitors
initial begin
    pc_monitor = 0;
    instr_monitor = 0;
    for (i = 0; i < 32; i=i+1) begin
        rf_monitor[i] = 0;
        mem_monitor[i] = 0;
    end
end

// Capture writes based on enables
always @(posedge clk) begin
    if (reset_n) begin
        if (we_pc) pc_monitor <= pc_monitor + 4;        // simulate PC increment
        if (we_ir) instr_monitor <= 32'hDEADBEEF;      // dummy instruction read
        if (we_rf) rf_monitor[1] <= 32'h1234;          // dummy write to x1
        if (we_mem) mem_monitor[0] <= 32'hABCD;        // dummy write to memory[0]
    end
end

// Task to run a complete instruction cycle and monitor outputs
task run_instruction_cycle;
    input [200*8:1] instr_name;
    integer cycle;
    begin
        cycle = 0;
        $display("  Executing: %s", instr_name);
        
        repeat(10) begin
            @(posedge clk);
            cycle = cycle + 1;
            #1;
            
            $display("    Cycle %0d: State=%b | we_pc=%b (PC=%h) | we_ir=%b (INSTR=%h) | we_rf=%b (RF[1]=%h) | we_mem=%b (MEM[0]=%h) | sel_result=%b | alu_ctrl=%b",
                     cycle, dut.state,
                     we_pc, pc_monitor,
                     we_ir, instr_monitor,
                     we_rf, rf_monitor[1],
                     we_mem, mem_monitor[0],
                     sel_result, alu_control);
            
            if (cycle > 1 && dut.state == 4'b0000) begin
                $display("    -> Instruction complete, returned to FETCH state\n");
                cycle = 10; // Exit early
            end
        end
    end
endtask

// Initialize signals and run tests
initial begin
    $dumpfile("controller_tb.vcd");
    $dumpvars(0, controller_tb);

    reset_n = 0; zero = 0; op = 7'b0000000; funct3 = 3'b000; funct7 = 0;
    #15; reset_n = 1; #10;

    $display("=== Starting Controller Testbench ===\n");

    // Test cases
    op = 7'b0110011; funct3 = 3'b000; funct7 = 0; zero = 0; run_instruction_cycle("R-type ADD");
    funct7 = 1; run_instruction_cycle("R-type SUB");

    op = 7'b0010011; funct3 = 3'b000; funct7 = 0; zero = 0; run_instruction_cycle("I-type ADDI");

    op = 7'b0000011; funct3 = 3'b010; funct7 = 0; zero = 0; run_instruction_cycle("Load LW");

    op = 7'b0100011; funct3 = 3'b010; funct7 = 0; zero = 0; run_instruction_cycle("Store SW");

    op = 7'b1100011; funct3 = 3'b000; funct7 = 0; zero = 0; run_instruction_cycle("Branch BEQ not taken");
    zero = 1; run_instruction_cycle("Branch BEQ taken");

    op = 7'b1101111; funct3 = 3'b000; funct7 = 0; zero = 0; run_instruction_cycle("JAL");

    op = 7'b0110111; funct3 = 3'b000; funct7 = 0; zero = 0; run_instruction_cycle("LUI");

    $display("\n=== Testbench Complete ===");
    #50;
    $finish;
end

// Monitor for invalid signal combinations
always @(posedge clk) begin
    if (reset_n && we_mem && we_rf)
        $display("WARNING: Both we_mem and we_rf asserted at time %0t", $time);
end

endmodule
