`timescale 1ns/1ps
`include "main.v"

module testbench;

reg clk;
reg rst;

rv_mc riscv_mc_inst (
    .clk(clk),
    .rst(rst)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//Initialize memory directly in the DUT
initial begin
    $readmemh("test.hex", riscv_mc_inst.MEM.RAM);
end

initial begin
    $dumpfile("riscv_test.vcd");
    $dumpvars(0, riscv_mc_inst);

    //Active low reset
    rst = 0;      
    #20;
    rst = 1; 

    #2000;

    $display("\n=== FINAL REGISTER DUMP ===");
    $display("x1  (LUI)        = 0x%h  (expect 0x12345000)", riscv_mc_inst.register_file.Registers[1]);
    $display("x2  (ADDI 10)    = %0d   (expect 10)", riscv_mc_inst.register_file.Registers[2]);
    $display("x3  (ADDI 20)    = %0d   (expect 20)", riscv_mc_inst.register_file.Registers[3]);
    $display("x4  (ADDI -5)    = %0d   (expect -5)", $signed(riscv_mc_inst.register_file.Registers[4]));
    $display("x5  (ADD)        = %0d   (expect 30)", riscv_mc_inst.register_file.Registers[5]);
    $display("x6  (SUB)        = %0d   (expect 10)", riscv_mc_inst.register_file.Registers[6]);
    $display("x10 (SLT)        = %0d   (expect 1)", riscv_mc_inst.register_file.Registers[10]);
    $display("x11 (SLTU)       = %0d   (expect 0)", riscv_mc_inst.register_file.Registers[11]);
    $display("x15 (BEQ flag)   = %0d   (expect 1)", riscv_mc_inst.register_file.Registers[15]);
    $display("x16 (BEQ taken)  = %0d   (expect 2)", riscv_mc_inst.register_file.Registers[16]);
    $display("x17 (JAL link)   = 0x%h", riscv_mc_inst.register_file.Registers[17]);
    $display("x19 (after JAL)  = %0d   (expect 77)", riscv_mc_inst.register_file.Registers[19]);

    $display("\n=== TEST COMPLETE ===");
    $finish;
end

initial begin
    #21;
    $display("DEBUG_AFTER_RESET: ctrl.sel_mem_addr=%b | ctrl.sel_result=%b | pc_reg=%h | mux4_output=%h", riscv_mc_inst.controller.sel_mem_addr, riscv_mc_inst.controller.sel_result, riscv_mc_inst.pc_reg, riscv_mc_inst.mux4_output);
end

always @(posedge clk) begin
    $display("Time=%0t | PC=%h | INSTR=%h | RD1=%h | RD2 = %h| we_ir=%b | we_pc=%b | State=%h", 
             $time, 
             riscv_mc_inst.pc_reg, 
             riscv_mc_inst.instr_reg, 
             riscv_mc_inst.rd1_reg,
             riscv_mc_inst.rd2_reg,
             riscv_mc_inst.we_ir, 
             riscv_mc_inst.we_pc,
             riscv_mc_inst.controller.state);
    $display("           mux1_out=%h | mem_read_data=%h | we_rf=%b | wd3=%h | rd_addr=%0d", 
             riscv_mc_inst.mux1_output, 
             riscv_mc_inst.read_data,
             riscv_mc_inst.we_rf,
             riscv_mc_inst.mux4_output,
             riscv_mc_inst.instr_reg[11:7]);
    $display("           ctrl.sel_mem_addr=%b | ctrl.sel_result=%b | ctrl.sel_alu_src_a=%b | ctrl.sel_alu_src_b=%b | alu_ctrl=%b | alu_out=%h", 
             riscv_mc_inst.controller.sel_mem_addr,
             riscv_mc_inst.controller.sel_result,
             riscv_mc_inst.controller.sel_alu_src_a,
             riscv_mc_inst.controller.sel_alu_src_b,
             riscv_mc_inst.alu_control,
             riscv_mc_inst.alu_output);
end

initial begin
    #30;  // After reset
    $display("\n=== MEMORY CONTENTS (first 10 words) ===");
    for (integer i = 0; i < 10; i = i + 1) begin
        $display("MEM[%0d] = 0x%h", i, riscv_mc_inst.MEM.RAM[i]);
    end
end

initial begin
    #10000;
    $display("ERROR: Simulation timeout!");
    $finish;
end

endmodule