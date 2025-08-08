module ALUCtrl (
    input [1:0] ALUOp,
    input [6:0] funct7,
    input [2:0] funct3,
    output reg [3:0] ALUCtl
);

    // TODO: implement your ALU ALUCtl here
   // Hint: using ALUOp, funct7, funct3 to select exact operation
always @(*) begin
    case (ALUOp)
        2'b00: begin
            ALUCtl = 4'b0000; 
        end

        2'b01: begin 
            case (funct3)
                3'b000: ALUCtl = 4'b0001; 
                3'b001: ALUCtl = 4'b0001; 
                3'b100: ALUCtl = 4'b0010; 
                3'b101: ALUCtl = 4'b0010;
                default: ALUCtl = 4'b1111;
            endcase
        end

        2'b10: begin 
            case ({funct7, funct3})
                10'b0000000_000: ALUCtl = 4'b0000; 
                10'b0100000_000: ALUCtl = 4'b0001; 
                10'b0000000_010: ALUCtl = 4'b0010; 
                10'b0000000_110: ALUCtl = 4'b0011; 
                10'b0000000_111: ALUCtl = 4'b0100; 
                default: ALUCtl = 4'b1111;
            endcase
        end

        2'b11: begin 
            case (funct3)
                3'b000: ALUCtl = 4'b0000; 
                3'b010: ALUCtl = 4'b0010; 
                3'b110: ALUCtl = 4'b0011; 
                3'b111: ALUCtl = 4'b0100;
                default: ALUCtl = 4'b1111;
            endcase
        end

        default: ALUCtl = 4'b1111;
    endcase
end
endmodule

