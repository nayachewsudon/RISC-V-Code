`timescale 1ns/1ps
`include "fsm.v"

module fsm_tb ();

    //DUT Inputs
    reg clk;
    reg [6:0] op;
    reg reset_n;

    //DUT Outputs
    wire [3:0] state;
    wire [1:0] sel_result;
    wire [1:0] sel_alu_src_b;
    wire [1:0] sel_alu_src_a;
    wire sel_mem_addr;
    wire we_mem;
    wire we_ir;
    wire we_rf;
    wire [1:0] alu_op; //only an output of FSM
    wire pc_update; //only an output of FSM
    wire branch;

    //DUT Instantiation
    fsm dut (
    .clk(clk),
    .op(op),
    .reset_n(reset_n),
    .state(state),
    .sel_result(sel_result),
    .sel_alu_src_a(sel_alu_src_a),
    .sel_alu_src_b(sel_alu_src_b),
    .sel_mem_addr(sel_mem_addr),
    .we_mem(we_mem),
    .we_ir(we_ir),
    .we_rf(we_rf),
    .alu_op(alu_op),
    .pc_update(pc_update),
    .branch(branch)
);

    //Waveform dump
    initial begin
        $dumpfile("fsm_dump.vcd");
        $dumpvars(0, fsm_tb);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    function [63:0] state_name;
        input [3:0] s;
        begin
            case(s)
                0: state_name = "FETCH";
                1: state_name = "DECODE";
                2: state_name = "EXE_ADDR";
                3: state_name = "MEM_RD";
                4: state_name = "WB_MEM";
                5: state_name = "MEM_WRITE";
                6: state_name = "EXE_R";
                7: state_name = "WB_ALU";
                8: state_name = "BEQ";
                9: state_name = "EXE_I";
                10: state_name = "JAL";
                11: state_name = "LUI";
                default: state_name = "UNKNOWN";
            endcase
        end
    endfunction

    initial begin
        //Initialize
        reset_n = 0; 
        op = 7'b0000000;

        #21;
        reset_n = 1;
        #1;

        //---TEST 1: LW INSTRUCTION---
        $display("Test 1: LW instruction");
        op = 7'b0000011; 
        #1;

        //S0: fetch
        $display("State: %s | we_ir=%b | sel_mem_addr=%b | pc_update=%b", 
                state_name(state), we_ir, sel_mem_addr, pc_update);
        if (state != 0) $display("Error: expected fetch state");
        if (we_ir != 1) $display ("Error: we_ir should be 1 in fetch");
        if (sel_mem_addr != 0) $display("Error: sel_mem_addr should be 0 in fetch");
        if (pc_update != 1) $display("Error: pc_update should be 1 in fetch");

        //S1: Decode
        @(posedge clk);
        #1;
        $display("State: %s", state_name(state));
        if (state != 1)$display("ERROR: expected decode state");

        //S2: Exe_addr
        @(posedge clk);
        #1;
        $display("State: %s | sel_alu_src_a=%b | sel_alu_src_b=%b | alu_op=%b", 
                state_name(state), sel_alu_src_a, sel_alu_src_b, alu_op);
        if (state != 2) $display("Error: expected exe_addr state");
        if (sel_alu_src_a != 2'b10) $display("Error: sel_alu_src_a should be 10");
        if (sel_alu_src_b != 2'b01) $display("Error: sel_alu_src_b should be 01");
        if (alu_op != 2'b00) $display ("Error: alu_op should be 00 (Add)");

        //S3: mem_rd
        @(posedge clk);
        #1;
        $display("State: %s | sel_mem_addr=%b | sel_result=%b", 
                state_name(state), sel_mem_addr, sel_result);
        if (state != 3) $display("ERROR: Expected MEM_RD state");
        if (sel_mem_addr != 1) $display("ERROR: sel_mem_addr should be 1");
        if (sel_result != 2'b00) $display("ERROR: sel_result should be 00");

        //S4: wb_mem
        @(posedge clk); 
        #1;
        $display("State: %s | we_rf=%b | sel_result=%b", 
                state_name(state), we_rf, sel_result);
        if (state != 4) $display("ERROR: Expected WB_MEM state");
        if (we_rf != 1) $display("ERROR: we_rf should be 1 in WB_MEM");
        if (sel_result != 2'b01) $display("ERROR: sel_result should be 01");

        //Return to fetch
        @(posedge clk);
        #1;
        $display("State: %s (back to FETCH)", state_name(state));
        if (state != 0) $display("ERROR: Should return to FETCH");

        //---TEST 2: SW INSTRUCTION--
        $display("Test 2: SW Instruction");
        op = 7'b0100011;
        #1;

        //S0: fetch - check current state first
        $display("State: %s | we_ir=%b | sel_mem_addr=%b | pc_update=%b", 
                state_name(state), we_ir, sel_mem_addr, pc_update);
        if (state != 0) $display("Error: expected fetch state");
        if (we_ir != 1) $display ("Error: we_ir should be 1 in fetch");
        if (sel_mem_addr != 0) $display("Error: sel_mem_addr should be 0 in fetch");
        if (pc_update != 1) $display("Error: pc_update should be 1 in fetch");

        //S1: Decode
        @(posedge clk);
        #1;
        $display("State: %s", state_name(state));
        if (state != 1)$display("ERROR: expected decode state");

        //S2: Exe_addr
        @(posedge clk);
        #1;
        $display("State: %s | sel_alu_src_a=%b | sel_alu_src_b=%b | alu_op=%b", 
                state_name(state), sel_alu_src_a, sel_alu_src_b, alu_op);
        if (state != 2) $display("Error: expected exe_addr state");
        if (sel_alu_src_a != 2'b10) $display("Error: sel_alu_src_a should be 10");
        if (sel_alu_src_b != 2'b01) $display("Error: sel_alu_src_b should be 01");
        if (alu_op != 2'b00) $display ("Error: alu_op should be 00 (Add)");

        //S5: Mem write
        @(posedge clk);
        #1;
        $display("State: %s | we_mem=%b | sel_mem_addr=%b", 
                state_name(state), we_mem, sel_mem_addr);
        if (state != 5) $display("ERROR: Expected MEM_WRITE state");
        if (we_mem != 1) $display("ERROR: we_mem should be 1 in MEM_WRITE");

        //S0: fetch again
        @(posedge clk); 
        #1;
        $display("State: %s (back to FETCH)", state_name(state));

        //---TEST 3: R-TYPE INSTRUCTIONS --
        $display("Test 3: R-type instructions");
        op = 7'b0110011;
        #1;

        //FETCH
        $display("State: %s (FETCH)", state_name(state));

        //DECODE
        @(posedge clk);
        #1;
        $display("State: %s (DECODE)", state_name(state));

        //S6: EXE_R
        @(posedge clk);
        #1;
        $display("State: %s | sel_alu_src_a=%b | sel_alu_src_b=%b | alu_op=%b", 
                state_name(state), sel_alu_src_a, sel_alu_src_b, alu_op);
        if (state != 6) $display("ERROR: Expected EXE_R state");
        if (alu_op != 2'b10) $display("ERROR: alu_op should be 10 for R-type");

        //S7: WB_ALU
        @(posedge clk);
        #1;
        $display("State: %s | we_rf=%b", state_name(state), we_rf);
        if (state != 7) $display("ERROR: Expected WB_ALU state");
        if (we_rf != 1) $display("ERROR: we_rf should be 1");

        //S0: fetch again
        @(posedge clk);
        #1;
        $display("State: %s (back to FETCH)", state_name(state));

        //--TEST 4: BEQ INSTRUCTION --
        $display("Test 4: BEQ Instruction (opcode 1100011)");
        op = 7'b1100011;
        #1;

        //FETCH
        $display("State: %s (FETCH)", state_name(state));

        //DECODE
        @(posedge clk);
        #1;
        $display("State: %s (DECODE)", state_name(state));

        //S8: BEQ
        @(posedge clk);
        #1;
        $display("State: %s | branch=%b | alu_op=%b", 
                state_name(state), branch, alu_op);
        if (state != 8) $display("ERROR: Expected BEQ state");
        if (branch != 1) $display("ERROR: branch should be 1");
        if (alu_op != 2'b01) $display("ERROR: alu_op should be 01 for branch");

        //Fetch again
        @(posedge clk); 
        #1;
        $display("State: %s (back to FETCH)", state_name(state));

        //--TEST 5: LUI INSTRUCTION--
        $display("Test 5: LUI Instruction (opcode 0110111)");
        op = 7'b0110111;
        #1;

        //FETCH
        $display("State: %s (FETCH)", state_name(state));

        //DECODE
        @(posedge clk);
        #1;
        $display("State: %s (DECODE)", state_name(state));

        @(posedge clk); // LUI
        #1;
        $display("State: %s | we_rf=%b | sel_result=%b", 
                state_name(state), we_rf, sel_result);
        if (state != 11) $display("ERROR: Expected LUI state");
        if (we_rf != 1) $display("ERROR: we_rf should be 1");
        if (sel_result != 2'b10) $display("ERROR: sel_result should be 10");

        //FETCH
        @(posedge clk);
        #1;
        $display("State: %s (back to FETCH)", state_name(state));

        $display("\n=== All tests complete ===");
        #20;
        $finish;
    end

endmodule