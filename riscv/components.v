module programcounter (
    input [31:0] in_pc,
    input clk,
    input reset_pc,
    output reg [31:0] out_pc
);
    always @ (posedge clk or posedge reset_pc) begin 
     
        if (reset_pc) begin
            out_pc <= 32'b0;//reset value
        end
        else begin
            out_pc <= in_pc;
        end
    
    end
endmodule
//--------------------------------------------------------------------------------------------
//DELETED ADDERS IN RISC-V MULTICYCLE PROCESSORS
//--------------------------------------------------------------------------------------------
module mux_2to1 (
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
module mem #(parameter MEM_DEPTH = 32)(
    input [31:0] addr_memory,
    input [31:0] writedata,
    input we_mem,
    input clk, 
    input reset_n,
    output [31:0] read_data

); 

reg [31:0] RAM [0:MEM_DEPTH -1];
integer i; 

//Initialize memory (to help testing)
initial begin
    $readmemh("test.hex", RAM);
end

assign read_data = RAM[addr_memory[7:2]];

always @ (posedge clk or negedge reset_n) begin 
    if (!reset_n) begin
        for (i = 0; i < MEM_DEPTH; i++) begin
            RAM[i] = 32'h00000000;
        end
        $readmemh("test.hex", RAM); //Reload after reset
    end 
    else if (we_mem) begin 
        RAM[addr_memory[7:2]] = writedata; 
    end
end

endmodule


