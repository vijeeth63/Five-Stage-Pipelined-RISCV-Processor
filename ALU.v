module ALU (
    input [3:0] ALUCtl,
    input [31:0] A,B,
    output reg [31:0] ALUOut,
    output zero
);
    // ALU has two operand, it execute different operator based on ALUctl wire 
    // output zero is for determining taking branch or not 

    // TODO: implement your ALU here
    // Hint: you can use operator to implement
    always @(*) begin
    case (ALUCtl)
        4'b0000: ALUOut = A + B;       
        4'b0001: ALUOut = A - B;       
        4'b0010: ALUOut = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; 
        4'b0011: ALUOut = A | B;         
        4'b0100: ALUOut = A & B;         
        default: ALUOut = 32'b0;         
    endcase
end

assign zero = (ALUOut == 0) ? 1'b1 : 1'b0;


    
    
    
endmodule

