module PipelinedCPU(
    input clk,
    input reset
);
   
    wire [31:0] pc, pc_plus4, pc_branch, pc_next;
    wire [31:0] instruction;

    reg [31:0] IF_ID_instr, IF_ID_pc;

    wire [6:0] opcode = IF_ID_instr[6:0];
    wire [4:0] rs1 = IF_ID_instr[19:15];
    wire [4:0] rs2 = IF_ID_instr[24:20];
    wire [4:0] rd  = IF_ID_instr[11:7];
    wire [2:0] funct3 = IF_ID_instr[14:12];
    wire [6:0] funct7 = IF_ID_instr[31:25];
    wire [31:0] imm_out, read_data1, read_data2;
    wire branch, memRead, memtoReg, memWrite, ALUSrc, regWrite;
    wire [1:0] ALUOp;

    reg [31:0] ID_EX_pc, ID_EX_imm, ID_EX_read_data1, ID_EX_read_data2;
    reg [4:0] ID_EX_rs1, ID_EX_rs2, ID_EX_rd;
    reg [2:0] ID_EX_funct3;
    reg [6:0] ID_EX_funct7;
    reg [1:0] ID_EX_ALUOp;
    reg ID_EX_branch, ID_EX_memRead, ID_EX_memtoReg, ID_EX_memWrite, ID_EX_ALUSrc, ID_EX_regWrite;
 
    wire [3:0] ALUCtl_out;
    wire [31:0] alu_inputA, alu_inputB, alu_result;
    wire zero;
    wire [1:0] forwardA, forwardB;

    reg [31:0] EX_MEM_alu_result, EX_MEM_write_data, EX_MEM_pc_branch;
    reg [4:0] EX_MEM_rd;
    reg EX_MEM_branch_taken, EX_MEM_memRead, EX_MEM_memtoReg, EX_MEM_memWrite, EX_MEM_regWrite;

    wire [31:0] data_memory_out;

    reg [31:0] MEM_WB_data_memory_out, MEM_WB_alu_result;
    reg [4:0] MEM_WB_rd;
    reg MEM_WB_memtoReg, MEM_WB_regWrite;

    wire [31:0] write_data;

    wire branch_taken = ID_EX_branch & zero;

wire stall;
HazardDetection hazard_unit (
    .ID_rs1(rs1),
    .ID_rs2(rs2),
    .EX_rd(ID_EX_rd),
    .EX_memRead(ID_EX_memRead),
    .stall(stall)
);

    assign pc_next = branch_taken ? pc_branch : pc_plus4;

    PC pc_inst(.clk(clk), .rst(reset),.enable(~stall), .pc_i(pc_next), .pc_o(pc));
    Adder adder_pc4(.a(pc), .b(32'd4), .sum(pc_plus4));
    InstructionMemory instr_mem(.readAddr(pc), .inst(instruction));

    always @(posedge clk) begin
        if (!reset || stall || branch_taken) begin
            IF_ID_instr <= 32'b0;
            IF_ID_pc <= 32'b0;
        end else begin
            IF_ID_instr <= instruction;
            IF_ID_pc <= pc;
        end
    end

    Control ctrl(.opcode(opcode), .branch(branch), .memRead(memRead),
                 .memtoReg(memtoReg), .ALUOp(ALUOp), .memWrite(memWrite),
                 .ALUSrc(ALUSrc), .regWrite(regWrite));

    Register reg_file(.clk(clk), .rst(reset), .regWrite(MEM_WB_regWrite),
                      .readReg1(rs1), .readReg2(rs2), .writeReg(MEM_WB_rd),
                      .writeData(write_data), .readData1(read_data1),
                      .readData2(read_data2));

    ImmGen imm_gen(.inst(IF_ID_instr), .imm(imm_out));

    always @(posedge clk) begin
        if (!reset || stall || branch_taken) begin
            ID_EX_branch <= 0; ID_EX_memRead <= 0; ID_EX_memtoReg <= 0;
            ID_EX_memWrite <= 0; ID_EX_ALUSrc <= 0; ID_EX_regWrite <= 0;
            ID_EX_ALUOp <= 0;
            ID_EX_pc <= 0; ID_EX_imm <= 0; ID_EX_read_data1 <= 0; ID_EX_read_data2 <= 0;
            ID_EX_rs1 <= 0; ID_EX_rs2 <= 0; ID_EX_rd <= 0;
            ID_EX_funct3 <= 0; ID_EX_funct7 <= 0;
        end else begin
            ID_EX_pc <= IF_ID_pc;
            ID_EX_imm <= imm_out;
            ID_EX_read_data1 <= read_data1;
            ID_EX_read_data2 <= read_data2;
            ID_EX_rs1 <= rs1;
            ID_EX_rs2 <= rs2;
            ID_EX_rd <= rd;
            ID_EX_funct3 <= funct3;
            ID_EX_funct7 <= funct7;
            ID_EX_branch <= branch;
            ID_EX_memRead <= memRead;
            ID_EX_memtoReg <= memtoReg;
            ID_EX_memWrite <= memWrite;
            ID_EX_ALUSrc <= ALUSrc;
            ID_EX_regWrite <= regWrite;
            ID_EX_ALUOp <= ALUOp;
        end
    end

    ALUCtrl alu_ctrl(.ALUOp(ID_EX_ALUOp), .funct7(ID_EX_funct7), .funct3(ID_EX_funct3), .ALUCtl(ALUCtl_out));

    ForwardingUnit fwd(.EX_rs1(ID_EX_rs1), .EX_rs2(ID_EX_rs2), .MEM_rd(EX_MEM_rd),
                       .WB_rd(MEM_WB_rd), .MEM_regWrite(EX_MEM_regWrite),
                       .WB_regWrite(MEM_WB_regWrite), .forwardA(forwardA), .forwardB(forwardB));

    Mux3to1 muxA(.sel(forwardA), .in0(ID_EX_read_data1), .in1(write_data), .in2(EX_MEM_alu_result), .out(alu_inputA));
    Mux3to1 muxB(.sel(forwardB), .in0(ID_EX_read_data2), .in1(write_data), .in2(EX_MEM_alu_result), .out(alu_inputB));

    wire [31:0] alu_inputB_final;
    Mux2to1 #(.size(32)) alu_src_mux(.sel(ID_EX_ALUSrc), .s0(alu_inputB), .s1(ID_EX_imm), .out(alu_inputB_final));

    ALU alu(.ALUCtl(ALUCtl_out), .A(alu_inputA), .B(alu_inputB_final), .ALUOut(alu_result), .zero(zero));

    Adder branch_adder(.a(ID_EX_pc), .b(ID_EX_imm), .sum(pc_branch));

    always @(posedge clk) begin
        if (!reset) begin
            EX_MEM_branch_taken <= 0;
            EX_MEM_memRead <= 0; EX_MEM_memtoReg <= 0;
            EX_MEM_memWrite <= 0; EX_MEM_regWrite <= 0;
        end else begin
            EX_MEM_alu_result <= alu_result;
            EX_MEM_pc_branch <= pc_branch;
            EX_MEM_write_data <= alu_inputB;
            EX_MEM_rd <= ID_EX_rd;
            EX_MEM_branch_taken <= branch_taken;
            EX_MEM_memRead <= ID_EX_memRead;
            EX_MEM_memtoReg <= ID_EX_memtoReg;
            EX_MEM_memWrite <= ID_EX_memWrite;
            EX_MEM_regWrite <= ID_EX_regWrite;
        end
    end

    DataMemory dmem(.rst(reset), .clk(clk), .memWrite(EX_MEM_memWrite),
                    .memRead(EX_MEM_memRead), .address(EX_MEM_alu_result),
                    .writeData(EX_MEM_write_data), .readData(data_memory_out));

    always @(posedge clk) begin
        if (!reset) begin
            MEM_WB_regWrite <= 0; MEM_WB_memtoReg <= 0;
        end else begin
            MEM_WB_data_memory_out <= data_memory_out;
            MEM_WB_alu_result <= EX_MEM_alu_result;
            MEM_WB_rd <= EX_MEM_rd;
            MEM_WB_regWrite <= EX_MEM_regWrite;
            MEM_WB_memtoReg <= EX_MEM_memtoReg;
        end
    end

    Mux2to1 #(.size(32)) wb_mux(.sel(MEM_WB_memtoReg), .s0(MEM_WB_alu_result), .s1(MEM_WB_data_memory_out), .out(write_data));
endmodule
