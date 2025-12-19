//--------------------------------------------------------------------------------------------
//DELETED ADDERS AND PROGRAM COUNTER IN RISC-V MULTICYCLE PROCESSORS
//--------------------------------------------------------------------------------------------
module mux_2to1 (
    input [31:0] in_a, in_b,
    input sel,
    output reg [31:0] out_m
); 

always @(*) begin
   if (sel) begin
        out_m = in_b;
    end
    else begin
        out_m = in_a;
    end
end

endmodule
//--------------------------------------------------------------------------------------------
module mux_3to1 (
    input [31:0] in_a, in_b, in_c,
    input [1:0] sel,
    output reg [31:0] out_m
); 

always @(*) begin
    case (sel)
    2'b00: begin
        out_m = in_a;
    end
    2'b01: begin 
        out_m = in_b;
    end
    2'b10: begin
        out_m = in_c;
    end
    default: begin
        out_m = 32'b0;
    end
    endcase
end
endmodule
//--------------------------------------------------------------------------------------------
module mux_3to1_offset(
    input [31:0] in_a, in_b,
    input [1:0] sel,
    output reg [31:0] out
);

   always @(*) begin
    case (sel)
    2'b00: begin
        out = in_a;
    end
    2'b01: begin 
        out = in_b;
    end
    2'b10: begin
        out = 32'd4;
    end
    default: begin
        out = 32'b0;
    end
    endcase
   end
endmodule
//--------------------------------------------------------------------------------------------

module mux_4to1_andzero( //For LUI
    input [31:0] in_a, in_b,in_c,
    input [1:0] sel,
    output reg [31:0] out
);

   always @(*) begin
    case (sel)
    2'b00: begin
        out = in_a;
    end
    2'b01: begin 
        out = in_b;
    end
    2'b10: begin
        out = in_c;
    end
    2'b11: begin //For LUI 
        out = 32'b0;
    end
    default: begin
        out = 32'bx;
    end
    endcase
   end
endmodule
//--------------------------------------------------------------------------------------------
module register_file(
    input clk_r, 
    input reset_n,
    input [4:0] a1, //register addresses
    input [4:0] a2, 
    input [4:0] a3, 
    input [31:0] wd3, //data to write
    output [31:0] rd1, rd2, //dst registers
    input we3 //write enable bit
);

reg [31:0] Registers [31:0];
integer i; 

assign rd1 = Registers[a1];
assign rd2 = Registers[a2];

always @ (posedge clk_r or negedge reset_n) begin
    if (!reset_n) begin
        for (i = 0; i<32; i = i+1) begin
           Registers[i] <= 32'd0; 
        end
    end
    else if (we3 && a3 != 0) begin
        Registers[a3] <= wd3;
    end 
end

endmodule
//--------------------------------------------------------------------------------------------
module mem #(parameter MEM_DEPTH = 32)(
    input [31:0] addr_memory,
    input [31:0] writedata,
    input we_mem,
    input clk, 
    output [31:0] read_data

); 

reg [31:0] RAM [0:MEM_DEPTH -1];
integer i; 

assign read_data = RAM[addr_memory[6:2]];

//Active low reset logic - reset active (0) => clear memory + reload from file 
always @ (posedge clk) begin
    if (we_mem) begin 
        RAM[addr_memory[6:2]] <= writedata; 
    end
end

endmodule


