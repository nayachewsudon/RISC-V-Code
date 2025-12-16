module instruction_decoder(
    input [6:0] op,
    output reg [2:0] sel_ext
);
always @ (*) begin
    case (op) 
    0000011: begin //lw
        sel_ext = 3'b000;
    end
    0100011: begin //sw
        sel_ext = 3'b001;
    end
    0010011: begin //I -type
        sel_ext = 3'b000;
    end
    1100011: begin //B-Type
        sel_ext = 3'b011;
    end
    1101111: begin //J-type
        sel_ext = 3'b100;
    end
    0110111: begin //LUI
        sel_ext = 3'b101;
    end
    default: sel_ext = 3'b111; //Any input from R-Type or incorrect types
    endcase
end
endmodule