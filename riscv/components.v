module programcounter (
    input [31:0] input_pc,
    input clk,
    input reset,
    output reg [31:0] updated_pc
);
    always @ (posedge clk) begin 
     
        if (reset) begin
            updated_pc <= 32'b0;//reset value
        end
        else begin
            updated_pc <= input_pc;
        end
    
    end
endmodule
//--------------------------------------------------------------------------------------------
module adder ( 
    input [31:0] pc,
    output reg [31:0] pc_plus_4
); 

always @(*) begin
    pc_plus_4 <= 4 + pc;
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
        out_m <= in_a; 
    end 
    else begin 
        out_m <= in_b;
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
        out_m <= in_a;
    end
    2'b01: begin //dm
        out_m <= in_b;
    end
    2'b10: begin //pc+4
        out_m <= in_c;
    end
    default: begin
        out_m <= 32'bx;
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
           Registers[i] <= 32'd0; 
        end
    end
    else if (we3 && a3 != 0) begin
        Registers[a3] <= wd3;
    end 
end

endmodule
//--------------------------------------------------------------------------------------------
module instruction_memory ( 
    input [31:0] a_im, 
    output [31:0] rd_im
);

reg [31:0] RAM [63:0]; // initialize memory storage
integer i; 

//Initialize memory (to help testing)
initial begin
    $readmemh("test.hex", RAM);
end

assign rd_im = RAM[a_im[7:2]];

endmodule

//--------------------------------------------------------------------------------------------
module data_memory( 
    input [31:0] a_dm, //read instruction
    input clk, reset,
    input [31:0] wd_dm, //data to write
    input we,
    output [31:0] rd_dm 
);

reg [31:0] Memory [31 : 0];
integer i;
assign rd_dm = Memory[a_dm >> 2];

always @ (posedge clk) begin
    if (we) begin 
        Memory[a_dm [6:2]] = wd_dm; 
    end
end


endmodule