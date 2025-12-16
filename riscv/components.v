module programcounter (
    input [31:0] in_pc,
    input clk_pc,
    input reset_pc,
    output reg [31:0] out_pc
);
    always @ (posedge clk_pc or posedge reset_pc) begin 
     
        if (reset_pc) begin
            out_pc <= 32'b0;//reset value
        end
        else begin
            out_pc <= in_pc;
        end
    
    end
endmodule
//--------------------------------------------------------------------------------------------
module adder ( //TODO:bener kagak?
    input [31:0] pc,
    output reg [31:0] pc_plus_4
); 

always @(*) begin
    pc_plus_4 = 4 + pc;
end

endmodule
//--------------------------------------------------------------------------------------------
module adder_general (
    input [31:0] a, 
    input [31:0] b, 
    output [31:0] sum
);
    assign sum = a + b; 
endmodule
//--------------------------------------------------------------------------------------------
module multiplexer (
    input [31:0] in_a, in_b,
    input sel,
    output reg [31:0] out_m
); 

always @(*) begin
   if (sel) begin 
        out_m = in_a; 
    end 
    else begin 
        out_m = in_b;
    end 
end

endmodule
//--------------------------------------------------------------------------------------------
module mux_3to1 (
    input [31:0] in_a, in_b, in_c,
    input [1:0] sel_res,
    output reg [31:0] out_m
); 

always @(*) begin
    case (sel_res)
    2'b00: begin //alu
        out_m = in_a;
    end
    2'b01: begin //dm
        out_m = in_b;
    end
    2'b10: begin //pc+4
        out_m = in_c;
    end
    default: begin
        out_m = 32'b0;
    end
    endcase
end
endmodule
//--------------------------------------------------------------------------------------------
module register_file(
    input clk_r, 
    input reset_r,
    input [4:0] a1, //register addresses
    input [4:0] a2, 
    input [4:0] a3, 
    input [31:0] wd3, //data to write
    output [31:0] rd1, rd2, //dst registers
    input we3 //write enable bit
);

reg [31:0] Registers [63:0]; //the 32 addresses in the register file from x0 to x32
integer i; 

assign rd1 = Registers[a1];
assign rd2 = Registers[a2];

always @ (posedge clk_r or posedge reset_r) begin
    if (reset_r) begin
        for (i = 0; i<64; i = i+1) begin
           Registers[i] = 32'd0; 
        end
    end
    else if (we3 && a3 != 0) begin
        Registers[a3] = wd3;
    end 
end

endmodule
//--------------------------------------------------------------------------------------------
module memory #(parameter MEM_DEPTH = 64)(
    input [31:0] addr_memory,
    input [31:0] writedata,
    input we_mem,
    input clk, 
    input reset_n,
    output [31:0] read_data

); 

reg [31:0] Memory [0:MEM_DEPTH -1]; // Change this to MEM_DEPTH -1
integer i; 

//Initialize memory (to help testing)
initial begin
    $readmemh("test.hex", Memory);
end

assign read_data = Memory[addr_memory[7:2]]; //rd_im intermediate register

always @ (posedge clk or negedge reset_n) begin 
    if (!reset_n) begin
        for (i = 0; i < MEM_DEPTH; i++) begin
            Memory[i] = 32'h00000000;
        end
        $readmemh("test.hex", Memory); //Reload after reset
    end 
    else if (we_mem) begin 
        Memory[addr_memory[7:2]] = writedata; 
    end
end

endmodule


