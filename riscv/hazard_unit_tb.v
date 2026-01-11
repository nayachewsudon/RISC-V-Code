`timescale 1ns/1ps
`include "hazard_unit.v"

module hazard_unit_tb;

// Inputs
reg [4:0] E_rs1;
reg [4:0] E_rs2;
reg M_we_rf;
reg W_we_rf;
reg [4:0] W_rf_a3;
reg [4:0] M_rf_a3;
reg [1:0] E_sel_result;
reg [4:0] E_rf_a3;
reg [4:0] D_rs1;
reg [4:0] D_rs2;
reg sel_pc;

// Outputs
wire [1:0] E_forward_a;
wire [1:0] E_forward_b;
wire E_flush;
wire D_stall;
wire F_stall;
wire D_flush;

// Instantiate the hazard unit
hazard_unit UUT (
    .E_rs1(E_rs1),
    .E_rs2(E_rs2),
    .M_we_rf(M_we_rf),
    .W_we_rf(W_we_rf),
    .W_rf_a3(W_rf_a3),
    .M_rf_a3(M_rf_a3),
    .E_forward_a(E_forward_a),
    .E_forward_b(E_forward_b),
    .E_sel_result(E_sel_result),
    .E_rf_a3(E_rf_a3),
    .D_rs1(D_rs1),
    .D_rs2(D_rs2),
    .E_flush(E_flush),
    .D_stall(D_stall),
    .F_stall(F_stall),
    .sel_pc(sel_pc),
    .D_flush(D_flush)
);

// Test counter
integer test_num = 0;
integer passed = 0;
integer failed = 0;

// Task to check results
task check_forwarding;
    input [1:0] expected_fwd_a;
    input [1:0] expected_fwd_b;
    begin
        #1; // Small delay for combinational logic
        test_num = test_num + 1;
        if (E_forward_a === expected_fwd_a && E_forward_b === expected_fwd_b) begin
            $display("PASS Test %0d: Forward_a=%b (expected %b), Forward_b=%b (expected %b)", 
                     test_num, E_forward_a, expected_fwd_a, E_forward_b, expected_fwd_b);
            passed = passed + 1;
        end else begin
            $display("FAIL Test %0d: Forward_a=%b (expected %b), Forward_b=%b (expected %b)", 
                     test_num, E_forward_a, expected_fwd_a, E_forward_b, expected_fwd_b);
            failed = failed + 1;
        end
    end
endtask

task check_stall;
    input expected_d_stall;
    input expected_f_stall;
    input expected_e_flush;
    begin
        #1;
        test_num = test_num + 1;
        if (D_stall === expected_d_stall && F_stall === expected_f_stall && E_flush === expected_e_flush) begin
            $display("PASS Test %0d: D_stall=%b (expected %b), F_stall=%b (expected %b), E_flush=%b (expected %b)",
                     test_num, D_stall, expected_d_stall, F_stall, expected_f_stall, E_flush, expected_e_flush);
            passed = passed + 1;
        end else begin
            $display("FAIL Test %0d: D_stall=%b (expected %b), F_stall=%b (expected %b), E_flush=%b (expected %b)",
                     test_num, D_stall, expected_d_stall, F_stall, expected_f_stall, E_flush, expected_e_flush);
            failed = failed + 1;
        end
    end
endtask

task check_control_hazard;
    input expected_d_flush;
    input expected_e_flush;
    begin
        #1;
        test_num = test_num + 1;
        if (D_flush === expected_d_flush && E_flush === expected_e_flush) begin
            $display("PASS Test %0d: D_flush=%b (expected %b), E_flush=%b (expected %b)",
                     test_num, D_flush, expected_d_flush, E_flush, expected_e_flush);
            passed = passed + 1;
        end else begin
            $display("FAIL Test %0d: D_flush=%b (expected %b), E_flush=%b (expected %b)",
                     test_num, D_flush, expected_d_flush, E_flush, expected_e_flush);
            failed = failed + 1;
        end
    end
endtask

initial begin
    $display("\n========================================");
    $display("  HAZARD UNIT TESTBENCH");
    $display("========================================\n");
    
    // Initialize all inputs
    E_rs1 = 0;
    E_rs2 = 0;
    M_we_rf = 0;
    W_we_rf = 0;
    W_rf_a3 = 0;
    M_rf_a3 = 0;
    E_sel_result = 2'b00;
    E_rf_a3 = 0;
    D_rs1 = 0;
    D_rs2 = 0;
    sel_pc = 0;
    #10;
    
    //===========================================
    // FORWARDING TESTS
    //===========================================
    $display("\n--- FORWARDING TESTS ---\n");
    
    // Test 1: No forwarding needed
    $display("Test 1: No forwarding - no write enables");
    E_rs1 = 5'd2;
    E_rs2 = 5'd3;
    M_we_rf = 0;
    W_we_rf = 0;
    M_rf_a3 = 5'd1;
    W_rf_a3 = 5'd4;
    check_forwarding(2'b00, 2'b00);
    
    // Test 2: Forward from MEM stage (rs1)
    $display("Test 2: Forward rs1 from MEM stage");
    E_rs1 = 5'd2;
    E_rs2 = 5'd3;
    M_we_rf = 1;
    W_we_rf = 0;
    M_rf_a3 = 5'd2;  // Match rs1
    W_rf_a3 = 5'd4;
    check_forwarding(2'b10, 2'b00);
    
    // Test 3: Forward from WB stage (rs1)
    $display("Test 3: Forward rs1 from WB stage");
    E_rs1 = 5'd2;
    E_rs2 = 5'd3;
    M_we_rf = 0;
    W_we_rf = 1;
    M_rf_a3 = 5'd1;
    W_rf_a3 = 5'd2;  // Match rs1
    check_forwarding(2'b01, 2'b00);
    
    // Test 4: Forward from MEM stage (rs2)
    $display("Test 4: Forward rs2 from MEM stage");
    E_rs1 = 5'd2;
    E_rs2 = 5'd3;
    M_we_rf = 1;
    W_we_rf = 0;
    M_rf_a3 = 5'd3;  // Match rs2
    W_rf_a3 = 5'd4;
    check_forwarding(2'b00, 2'b10);
    
    // Test 5: Forward from WB stage (rs2)
    $display("Test 5: Forward rs2 from WB stage");
    E_rs1 = 5'd2;
    E_rs2 = 5'd3;
    M_we_rf = 0;
    W_we_rf = 1;
    M_rf_a3 = 5'd1;
    W_rf_a3 = 5'd3;  // Match rs2
    check_forwarding(2'b00, 2'b01);
    
    // Test 6: Forward both operands from MEM
    $display("Test 6: Forward both from MEM stage");
    E_rs1 = 5'd2;
    E_rs2 = 5'd2;
    M_we_rf = 1;
    W_we_rf = 0;
    M_rf_a3 = 5'd2;  // Match both
    W_rf_a3 = 5'd4;
    check_forwarding(2'b10, 2'b10);
    
    // Test 7: Forward both operands from WB
    $display("Test 7: Forward both from WB stage");
    E_rs1 = 5'd5;
    E_rs2 = 5'd5;
    M_we_rf = 0;
    W_we_rf = 1;
    M_rf_a3 = 5'd1;
    W_rf_a3 = 5'd5;  // Match both
    check_forwarding(2'b01, 2'b01);
    
    // Test 8: MEM has priority over WB (rs1)
    $display("Test 8: MEM priority over WB for rs1");
    E_rs1 = 5'd2;
    E_rs2 = 5'd3;
    M_we_rf = 1;
    W_we_rf = 1;
    M_rf_a3 = 5'd2;  // Match rs1 in MEM
    W_rf_a3 = 5'd2;  // Also match rs1 in WB
    check_forwarding(2'b10, 2'b00);
    
    // Test 9: MEM has priority over WB (rs2)
    $display("Test 9: MEM priority over WB for rs2");
    E_rs1 = 5'd2;
    E_rs2 = 5'd3;
    M_we_rf = 1;
    W_we_rf = 1;
    M_rf_a3 = 5'd3;  // Match rs2 in MEM
    W_rf_a3 = 5'd3;  // Also match rs2 in WB
    check_forwarding(2'b00, 2'b10);
    
    // Test 10: Don't forward to x0
    $display("Test 10: No forwarding to x0");
    E_rs1 = 5'd0;  // x0 register
    E_rs2 = 5'd0;
    M_we_rf = 1;
    W_we_rf = 1;
    M_rf_a3 = 5'd0;
    W_rf_a3 = 5'd0;
    check_forwarding(2'b00, 2'b00);
    
    // Test 11: Mixed forwarding (rs1 from MEM, rs2 from WB)
    $display("Test 11: Forward rs1 from MEM, rs2 from WB");
    E_rs1 = 5'd2;
    E_rs2 = 5'd3;
    M_we_rf = 1;
    W_we_rf = 1;
    M_rf_a3 = 5'd2;  // Match rs1
    W_rf_a3 = 5'd3;  // Match rs2
    check_forwarding(2'b10, 2'b01);
    
    //===========================================
    // LOAD-USE HAZARD / STALL TESTS
    //===========================================
    $display("\n--- LOAD-USE HAZARD TESTS ---\n");
    
    // Reset control hazard signal
    sel_pc = 0;
    
    // Test 12: No load-use hazard
    $display("Test 12: No stall - not a load instruction");
    E_sel_result = 2'b00;  // Not a load
    E_rf_a3 = 5'd5;
    D_rs1 = 5'd2;
    D_rs2 = 5'd3;
    check_stall(1'b0, 1'b0, 1'b0);
    
    // Test 13: Load-use hazard on rs1
    $display("Test 13: Stall - load-use hazard on rs1");
    E_sel_result = 2'b01;  // Load instruction
    E_rf_a3 = 5'd2;        // Load destination
    D_rs1 = 5'd2;          // Next instruction uses it
    D_rs2 = 5'd3;
    check_stall(1'b1, 1'b1, 1'b1);
    
    // Test 14: Load-use hazard on rs2
    $display("Test 14: Stall - load-use hazard on rs2");
    E_sel_result = 2'b01;  // Load instruction
    E_rf_a3 = 5'd3;        // Load destination
    D_rs1 = 5'd2;
    D_rs2 = 5'd3;          // Next instruction uses it
    check_stall(1'b1, 1'b1, 1'b1);
    
    // Test 15: Load but no hazard (different registers)
    $display("Test 15: No stall - load to different register");
    E_sel_result = 2'b01;  // Load instruction
    E_rf_a3 = 5'd5;        // Load destination
    D_rs1 = 5'd2;          // Different registers
    D_rs2 = 5'd3;
    check_stall(1'b0, 1'b0, 1'b0);
    
    // Test 16: Load to x0 should not cause hazard
    $display("Test 16: No stall - load to x0");
    E_sel_result = 2'b01;  // Load instruction
    E_rf_a3 = 5'd0;        // Load to x0
    D_rs1 = 5'd0;
    D_rs2 = 5'd0;
    check_stall(1'b0, 1'b0, 1'b0);
    
    // Test 17: Load-use with one operand matching
    $display("Test 17: Stall - load-use on one operand");
    E_sel_result = 2'b01;
    E_rf_a3 = 5'd7;
    D_rs1 = 5'd7;  // Match
    D_rs2 = 5'd8;  // No match
    check_stall(1'b1, 1'b1, 1'b1);
    
    //===========================================
    // CONTROL HAZARD TESTS
    //===========================================
    $display("\n--- CONTROL HAZARD TESTS ---\n");
    
    // Reset load-use hazard signals
    E_sel_result = 2'b00;
    E_rf_a3 = 5'd0;
    D_rs1 = 5'd0;
    D_rs2 = 5'd0;
    
    // Test 18: No branch taken
    $display("Test 18: No flush - branch not taken");
    sel_pc = 0;
    check_control_hazard(1'b0, 1'b0);
    
    // Test 19: Branch taken
    $display("Test 19: Flush - branch taken");
    sel_pc = 1;
    check_control_hazard(1'b1, 1'b1);
    
    // Test 20: Combined load-use + branch
    $display("Test 20: Combined load-use + branch hazard");
    E_sel_result = 2'b01;
    E_rf_a3 = 5'd5;
    D_rs1 = 5'd5;
    D_rs2 = 5'd3;
    sel_pc = 1;
    #1;
    test_num = test_num + 1;
    if (D_stall === 1'b1 && F_stall === 1'b1 && E_flush === 1'b1 && D_flush === 1'b1) begin
        $display("PASS Test %0d: D_stall=%b, F_stall=%b, E_flush=%b, D_flush=%b", 
                 test_num, D_stall, F_stall, E_flush, D_flush);
        passed = passed + 1;
    end else begin
        $display("FAIL Test %0d: D_stall=%b (expected 1), F_stall=%b (expected 1), E_flush=%b (expected 1), D_flush=%b (expected 1)", 
                 test_num, D_stall, F_stall, E_flush, D_flush);
        failed = failed + 1;
    end
    
    //===========================================
    // SUMMARY
    //===========================================
    $display("\n========================================");
    $display("  TEST SUMMARY");
    $display("========================================");
    $display("  Total Tests: %0d", test_num);
    $display("  Passed:      %0d", passed);
    $display("  Failed:      %0d", failed);
    if (failed == 0) begin
        $display("\n  ALL TESTS PASSED!");
    end else begin
        $display("\n  SOME TESTS FAILED");
    end
    $display("========================================\n");
    
    $finish;
end

endmodule