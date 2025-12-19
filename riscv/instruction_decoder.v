module instruction_decoder(
    input [6:0] op,
    output reg [2:0] sel_ext
);
always @ (*) begin
    case (op) 
    7'b0000011: begin //lw
        sel_ext = 3'b000;
    end
    7'b0100011: begin //sw
        sel_ext = 3'b001;
    end
    7'b0010011: begin //I -type
        sel_ext = 3'b000;
    end
    7'b1100011: begin //B-Type
        sel_ext = 3'b011;
    end
    7'b1101111: begin //J-type
        sel_ext = 3'b100;
    end
    7'b0110111: begin //LUI
        sel_ext = 3'b101;
    end
    default: sel_ext = 3'b111; //Any input from R-Type or incorrect types
    endcase
end
endmodule