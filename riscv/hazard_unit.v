module hazard_unit (
    //Forwarding
    input [19:15] E_rs1,
    input [24:20] E_rs2,
    input M_we_rf,
    input W_we_rf,
    input [11:7] W_rf_a3,
    input [11:7] M_rf_a3,
    output reg E_forward_a, //Forwarding = control signal for 3to1 mux
    output reg E_forward_b, //Forwarding = control signal for 3to1 mux

    //Stalling - load hazard
    input [1:0] E_sel_result, 
    input [11:7] E_rf_a3,
    input [19:15] D_rs1,
    input [24:20] D_rs2,
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
        E_forward_a <= 10;
    end
    else if (((E_rs1 == W_rf_a3) && W_we_rf != 0) && E_rs1 != 0) begin
        E_forward_a <= 01; 
    end
    else begin
        E_forward_a <= 00; 
    end

    //Rs2
    if (((E_rs2 == M_rf_a3) && M_we_rf) && E_rs2 != 0) begin 
        E_forward_b <= 10;
    end
    else if (((E_rs2 == W_rf_a3) && W_we_rf != 0) && E_rs2 != 0) begin
        E_forward_b <= 01; 
    end
    else begin
        E_forward_b <= 00; 
    end
end

reg lw_stall = 0;

//Stalling - load hazard
always @(*) begin 
    lw_stall = E_sel_result & ((D_rs1 == E_rf_a3) | (D_rs2 == E_rf_a3)); //Fix

    if (lw_stall) begin
        D_stall <= 1; //Stall at decode 
        F_stall <= 1; //Stall at fetch
        E_flush <= 1; //Flush execute stage
    end
    else begin
        D_stall <= 0; 
        F_stall <= 0; 
        E_flush <= 0;
    end
end

//Control hazard handling

always @(*) begin
    D_flush <= sel_pc; 
    E_flush <= lw_stall | sel_pc;
end

endmodule