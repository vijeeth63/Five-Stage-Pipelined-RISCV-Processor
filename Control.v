module Control (
    input [6:0] opcode,
    output reg  branch,
    output reg  memRead,
    output reg  memtoReg,
    output reg [1:0] ALUOp,
    output reg memWrite,
    output reg ALUSrc,
    output reg  regWrite
   );

    // TODO: implement your Control here
    // Hint: follow the Architecture to set output signal
    
    
    always@(*) begin
        branch=0;
        memRead=0;
        memtoReg=0;
        ALUOp=2'b00;
        memWrite=0;
        ALUSrc=0;
        regWrite=0;
    
    case(opcode) 
        7'b0000011:begin
         branch=0;
        memRead=1;
        memtoReg=1;
        regWrite=1;
    ALUOp=2'b00;
    ALUSrc=1;
    end
    
    7'b0110011:begin
   regWrite=1;
    ALUOp=2'b10;
    branch=0;
        memRead=0;
        memtoReg=0;
        memWrite=0;
        ALUSrc=0;
    
    end
    
    7'b0010011: begin 
    regWrite  = 1;
    ALUSrc    = 1;
    ALUOp     = 2'b11; 
    memRead   = 0;
    memWrite  = 0;
    memtoReg  = 0;
    branch    = 0;
end

    
    7'b0100011:begin
    memWrite=1;
    ALUOp=2'b00;
    ALUSrc=1;
    branch=0;
        memRead=0;
        memtoReg=0;
        regWrite=0;
    end
    
    7'b1100011:begin
    branch=1;
    ALUOp=2'b01;
        memRead=0;
        memtoReg=0;
        memWrite=0;
        ALUSrc=0;
        regWrite=0;
    end
    
    7'b1101111:begin
    ALUOp=2'b10;
//    regWrite=1;
    ALUSrc=1;
    branch=0;
        memRead=0;
        memtoReg=0;
        memWrite=0;
        regWrite=0;
    end
    endcase
end
endmodule