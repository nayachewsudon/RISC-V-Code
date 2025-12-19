`timescale 1ns/1ps
`include "main.v"

module topmodule_tb();

    reg clk;
    reg rst;

    // Instantiate top-level
    rv_mc dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("main_tb.vcd");
        $dumpvars(0, topmodule_tb);

        // Reset sequence
        rst = 0;
        #15;
        rst = 1;

        // Run simulation for some cycles
        repeat(50) begin
            @(posedge clk);
            #1; // allow signals to stabilize

            $display("Time=%0t | PC=%h | OLD_PC=%h | INSTR=%h | RD1=%h | RD2=%h | ALU_REG=%h | DATA_REG=%h | we_pc=%b | we_ir=%b | we_rf=%b | we_mem=%b",
                     $time,
                     dut.pc_reg,
                     dut.old_pc_reg,
                     dut.instr_reg,
                     dut.rd1_reg,
                     dut.rd2_reg,
                     dut.alu_reg,
                     dut.data_reg,
                     dut.we_pc,
                     dut.we_ir,
                     dut.we_rf,
                     dut.we_mem
            );
        end

        $finish;
    end

endmodule
