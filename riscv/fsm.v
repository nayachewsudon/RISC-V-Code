module fsm(
    input clk,
    input [6:0] op,
    input reset_n,
    output reg [3:0] state,
    output reg [1:0] sel_result,
    output reg [1:0] sel_alu_src_b,
    output reg [1:0] sel_alu_src_a,
    output reg sel_mem_addr,
    output reg we_mem,
    output reg we_ir,
    output reg we_rf,
    output reg [1:0] alu_op, //only an output of FSM
    output reg pc_update, //only an output of FSM
    output reg branch //only an output of FSM
    //alu_control is not in FSM
);

    localparam FETCH = 0; 
    localparam DECODE = 1; 
    localparam EXE_ADDR = 2; 
    localparam MEM_RD = 3;
    localparam WB_MEM = 4;
    localparam MEM_WRITE = 5; 
    localparam EXE_R = 6; 
    localparam WB_ALU = 7; 
    localparam BEQ = 8; 
    localparam EXE_I = 9; 
    localparam JAL = 10;
    localparam LUI = 11; 
    reg [3:0] next;

    always @(posedge clk) begin
        if (!reset_n) 
            state <= FETCH; 
        else 
            state <= next; 
    end

    always@(*) begin
        next = state;
        we_ir = 0; 
        we_mem = 0;
        we_rf = 0;
        branch = 0;
        sel_result = 0; 
        sel_alu_src_b = 0; 
        sel_alu_src_a = 0;
        sel_mem_addr = 0;
        alu_op = 0; 
        pc_update = 0; 

        case (state) 
        FETCH: begin
            next = DECODE;
            sel_mem_addr = 0; 
            we_ir = 1; 
            sel_alu_src_a = 2'b00; 
            sel_alu_src_b = 2'b10; 
            alu_op = 2'b00; 
            sel_result = 2'b10; 
            pc_update = 1;
        end
        DECODE: begin
            if (op == 7'b0000011 || op == 7'b0100011) next = EXE_ADDR; 
            else if (op == 7'b0110011) next = EXE_R; 
            else if (op == 7'b0010011) next = EXE_I; 
            else if (op == 7'b1101111) next = JAL;
            else if (op == 7'b1100011) next = BEQ;
            //--ADDED NEW STATE LUI--
            else if(op == 7'b0110111) next = LUI;
        end

        EXE_ADDR: begin
            sel_alu_src_a = 2'b10;
            sel_alu_src_b = 2'b01; 
            alu_op = 2'b00;

            if (op == 7'b0000011) next = MEM_RD;
            else if (op == 7'b0100011) next= MEM_WRITE;
        end

        MEM_RD: begin
            sel_result = 2'b00; 
            sel_mem_addr = 1;
    
            next = WB_MEM;
        end

        WB_MEM: begin
            sel_result = 2'b01;
            we_rf = 1; 

            next = FETCH; 
            
        end
        MEM_WRITE: begin
            sel_result = 2'b00; 
            sel_mem_addr = 1; 
            we_mem = 1;

            next = FETCH;
            
        end

        EXE_R: begin
            sel_alu_src_a = 2'b10; 
            sel_alu_src_b = 2'b00;
            alu_op = 2'b10;

            next = WB_ALU; 
        end

        WB_ALU: begin
            sel_result = 2'b00; 
            we_rf = 1; 
    
            next = FETCH;
            
        end
        BEQ: begin
            sel_alu_src_a = 2'b10;
            sel_alu_src_b = 2'b00;
            alu_op = 2'b01; 
            sel_result = 2'b00;
            branch = 1; 

            next = FETCH;

        end
        EXE_I: begin
            sel_alu_src_a = 2'b10; 
            sel_alu_src_b = 2'b01; 
            alu_op = 2'b10;

            next = WB_ALU; 
            
        end
        JAL: begin
            sel_alu_src_a = 2'b01; 
            sel_alu_src_b = 2'b10; 
            alu_op = 2'b00; 
            sel_result = 2'b00;
            pc_update = 1; 

            next = WB_ALU;
        end
        //--NEW STATE LUI--
        LUI: begin
            sel_alu_src_a = 2'b01; 
            sel_alu_src_b = 2'b01; 
            sel_result = 2'b10; 
            alu_op = 2'b00; 
            we_rf = 1;
            next = FETCH; 
        end
        default: next = FETCH;

        endcase
    end

endmodule