module fsm(
    input clk,
    input [6:0] op, 
    //funct3 and funct7 are in alu decoder
    //reset
    input reset_n,
    output reg [3:0] state,
    output sel_result,
    output sel_alu_src_b,
    output sel_alu_src_a,
    output we_pc,
    output sel_mem_addr,
    output we_mem,
    output we_ir,
    output sel_ext,
    output we_rf,
    output alu_op,
    output pc_update, //not an output of fsm
    output branch
    //alu_control is not in FSM
);

    parameter FETCH = 0; 
    parameter DECODE = 1; 
    parameter EXE_ADDR = 2; 
    parameter MEM_RD = 3;
    parameter WB_MEM = 4;
    parameter MEM_WRITE = 5; 
    parameter EXE_R = 6; 
    parameter WB_ALU = 7; 
    parameter BEQ = 8; 
    parameter EXE_I = 9; 
    parameter JAL = 10;
    parameter [3:0] next; //TODO: check if i have to initiate

    always@(*) begin
        next = state;
        //TODO: check
        we_ir = 0; 
        we_mem = 0;
        we_rf = 0;
        branch = 0;

        case (state)
        FETCH:
            next = DECODE;
            sel_mem_addr = 0; 
            ir_we = 1; //TODO: check
            sel_alu_src_a = 00; 
            sel_alu_src_b = 10; 
            alu_op = 00; 
            sel_result = 10; 
            pc_update = 1; //TODO: check

        DECODE: begin
            if (op == 0000011 || op == 0100011) next = EXE_ADDR; 
            if (op == 0110011) next = EXE_R; 
            if (op == 0010011) next = EXE_I; 
            if (op == 1101111) next = JAL;
            if (op == 1100011) next = BEQ;
        end

        EXE_ADDR: begin
            sel_alu_src_a = 10;
            sel_alu_src_b = 01; 
            sel_sign_ext = 00;
            alu_op = 00;

            if (op == 0000011) next = MEM_RD;
            if (op == 0100011) next= MEM_WRITE;
        end

        MEM_RD: begin
            sel_result = 00; 
            sel_mem_addr = 1; //TODO: check
    
            next = WB_MEM;
        end

        WB_MEM: begin
            sel_result = 01;
            we_rf = 1; 

            next = FETCH; 
            
        end
        MEM_WRITE: begin
            sel_result = 00; 
            sel_mem_addr = 1; 
            we_mem = 1;

            next = FETCH;
            
        end

        EXE_R: begin
            sel_alu_src_a = 10; 
            sel_alu_src_b = 00;
            alu_op = 10;

            next = WB_ALU; 
        end

        WB_ALU: begin
            sel_result = 00; 
            we_rf = 1; 
    
            next = FETCH;
            
        end
        BEQ: begin
            sel_alu_src_a = 10;
            sel_alu_src_b = 00;
            alu_op = 01; 
            sel_result = 00;
            branch = 1; 

            next = FETCH;

        end
        EXE_I: begin
            sel_alu_src_a = 10; 
            sel_alu_src_b = 01; 
            alu_op = 10;

            next = WB_ALU; 
            
        end
        JAL: begin
            sel_alu_src_a = 01; 
            sel_alu_src_b = 10; 
            alu_op = 00; 
            sel_result = 00;
            pc_update = 1; 

            next = WB_ALU;
        end


        endcase
    end

endmodule