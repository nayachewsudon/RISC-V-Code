module programcounter (
    input [31:0] in_pc,
    input clk_pc,
    input reset_pc,
    output reg [31:0] out_pc,
);
always @ (posedge clk_pc or posedge reset_pc) begin //TODO: or do we just exclude posedge reset_pc? When to include reset_pc?
     
    if (reset_pc) begin
        out_pc <= 32'h00000000;//reset value
    end
    else begin
        out_pc <= in_pc;
    end
    
end
endmodule;
//--------------------------------------------------------------------------------------------
module adder ( //TODO: check if this works??
    input [31:0] pc, // TODO: how to connect the output of the pc to the input of the adder? 
    output reg [31:0] pc_plus_4
); 

assign pc_plus_4 = 4 + pc; // does a carry bit matter in a program counter? 

endmodule;
//--------------------------------------------------------------------------------------------
module multiplexer (
    input [31:0] in_a, in_b,
    input sel,
    output [31:0] out_m
); 

if (s == 1) begin 
        assign out_m = a; 
    end 
    else begin 
        assign out_m = b;
    end

endmodule; 
//--------------------------------------------------------------------------------------------
module register_file(
    input clk_r, 
    input reset_r,
    input [19:15] a1, //register addresses
    input [24:20] a2, 
    input [11:7] a3, 
    input [31:0] wd3, //data to write
    output [31:0] rd1, rd2, //dst registers
    input we3 //write enable bit
);

reg [31:0] Registers [31:0]; //the 32 addresses in the register file from x0 to x32
integer i; 

assign rd1 = Registers[a1];
assign rd2 = Registers[a2];

always @ (posedge clk_r or posedge reset_r) begin
    if (reset_r) begin
        for (i = 0; i<32; i = i +1)
        Registers[i] = 32'h00000000;
    end
    else if (we3) begin
        Registers[a3] = wd3;
    end
end

endmodule; 
//--------------------------------------------------------------------------------------------
module instruction_memory #(parameter N = 32)( //reset? 
    input [31:0] a_im, // TODO: verify that [7:2]is because instruction memory is ???? - depends on the PC+4 or PC+1
    output reg [31:0] rd_im
);

reg [31:0] Memory [0:N-1]; // initialize memory storage

assign rd_im = Memory[a_im]; //Todo: Must be wrong

//initial begin end
//to load the memory

endmodule;

//--------------------------------------------------------------------------------------------
module data_memory #(parameter N = 32)( //this one is still byte addressable
    input [31:0] a_dm, //read instruction
    input clk_dm, reset_dm,
    input [31:0] wd_dm, //data to write
    input we,
    output reg [31:0] rd_dm //register  
);

reg [31:0] memory [N-1 : 0];
integer i;
assign rd_dm = datamemory[a_dm];

always @ (posedge clk_dm) begin
    if (reset_dm) begin
        for (i = 0; i < N; i++) begin
            datamemory[i] = 32'h00000000;
        end
    end 
    if (we) begin 
        datamemory[a_dm] = wd_dm; 
    end
end


endmodule;