module ImmGen#(parameter Width = 32) (
    input [Width-1:0] inst,
    output reg signed [Width-1:0] imm
);
   

    wire [6:0] opcode = inst[6:0];
    always @(*) 
    begin
        case(opcode)
            
            // TODO: implement your ImmGen here
            // Hint: follow the RV32I opcode map table to set imm value
            7'b0000011, 7'b0010011: 
            imm = {{20{inst[31]}}, inst[31:20]};  

        7'b0100011:  
            imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};

        7'b1100011: 
            imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};

        7'b0110111, 
        7'b0010111:  
            imm = {inst[31:12], 12'b0};

        7'b1101111:  
            imm = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

        default:
            imm = 32'b0;
    endcase
end
	
            
endmodule

