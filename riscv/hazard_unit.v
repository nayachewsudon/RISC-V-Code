module hazard_unit (
    //Forwarding
    input [4:0] E_rs1,
    input [4:0] E_rs2,
    input M_we_rf,
    input W_we_rf,
    input [4:0] W_rf_a3,
    input [4:0] M_rf_a3,
    output reg [1:0] E_forward_a, //Forwarding = control signal for 3to1 mux
    output reg [1:0] E_forward_b, //Forwarding = control signal for 3to1 mux

    //Stalling - load hazard
    input [1:0] E_sel_result, 
    input [4:0] E_rf_a3,
    input [4:0] D_rs1,
    input [4:0] D_rs2,
    output reg E_flush,
    output reg D_stall,
    output reg F_stall,

    //Control hazard handling
    input sel_pc,
    output reg D_flush
);

//Forwarding
always @(*) begin
    //Fwd from memory stage - rs1
    if (((E_rs1 == M_rf_a3) && M_we_rf) && E_rs1 != 0) begin 
        E_forward_a <= 2'b10;
    end
    else if (((E_rs1 == W_rf_a3) && W_we_rf != 0) && E_rs1 != 0) begin
        E_forward_a <= 2'b01; 
    end
    else begin
        E_forward_a <= 2'b00; 
    end

    //Rs2
    if (((E_rs2 == M_rf_a3) && M_we_rf) && E_rs2 != 0) begin 
        E_forward_b <= 2'b10;
    end
    else if (((E_rs2 == W_rf_a3) && W_we_rf != 0) && E_rs2 != 0) begin
        E_forward_b <= 2'b01; 
    end
    else begin
        E_forward_b <= 2'b00; 
    end
end

reg lw_stall = 0;

always @(*) begin
    lw_stall = (E_sel_result == 2'b01) & ((D_rs1 == E_rf_a3) | (D_rs2 == E_rf_a3)) && (E_rf_a3 != 5'b0); //Alternatively, set E_sel_result == 1 and only take the last bit
end
//Stalling and flushing (handles control hazards + load hazards)
always @(*) begin 

    if (lw_stall) begin
        D_stall <= 1'b1; //Stall at decode 
        F_stall <= 1'b1; //Stall at fetch
        E_flush <= 1'b1; //Flush execute stage 
    end
    else begin
        D_stall <= 1'b0; 
        F_stall <= 1'b0; 
        E_flush <= sel_pc; //Implement E_flush = lw_stall | sel_pc logic
    end
    D_flush <= sel_pc; 
end

endmodule