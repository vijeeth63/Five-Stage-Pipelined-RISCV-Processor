module PC (
    input clk,
    input rst,
    input [31:0] pc_i,
    input enable,
    output reg [31:0] pc_o
);

always @(posedge clk ) begin
	if (~rst)
		pc_o <=32'b0;
	else if(enable)
		pc_o <= pc_i;
end
endmodule

