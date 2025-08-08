module HazardDetection(
    input [4:0] ID_rs1,
    input [4:0] ID_rs2,
    input [4:0] EX_rd,
    input EX_memRead,
    output reg  stall
);
    always @(*) begin
        
        if (EX_memRead && ((EX_rd == ID_rs1) || (EX_rd == ID_rs2))) begin
            stall = 1;
        end else begin
            stall = 0;
        end
    end
endmodule
