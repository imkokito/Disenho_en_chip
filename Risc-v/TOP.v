module TOP(
    input clk,
    input rst
);

wire [31:0] PC, PC_next, PC_plus, PC_target, instr;
wire [31:0] RD1, RD2, A, B; 


wire [31:0] ALUResult;
wire [31:0] imm_ext;
wire [31:0] read_data;
wire [31:0] result;

wire zero;

wire PCSrc;
wire [1:0] ResultSrc;
wire MemWrite;
wire ALUSrc;
wire RegWrite;
wire [1:0] ALUOp;
wire [1:0] ImmSrc;
wire [2:0] ALUControl;

//instancias
//PROGRAM COUNTER
PROGRAM_COUNTER pc_top (
    .clk(clk),
    .rst(rst),
    .PC(PC),
    .PC_next(PC_next)
);

//INSTRUCTION MEMORY
instruction_memory imem_top (
    .clk(clk),
    .A(PC),
    .RD(instr)
);

//PROGRAM COUNTER + 4
SUMADOR pc_mas_4(
    .A(PC),
    .B(4),
    .result(PC_plus)
);

//MAIN DECODER
MAIN_DECODER main_decoder_top(
    .opcode(instr[6:0]),
    .zero(zero),
    .PC_src(PCSrc),
    .Result_src(ResultSrc),
    .mem_write(MemWrite),
    .ALU_src(ALUSrc),
    .Reg_write(RegWrite),
    .ALU_op(ALUOp),
    .imm_src(ImmSrc)
);

//ALU DECODER
ALU_DECODER alu_decoder_top(
    .ALUOp(ALUOp),
    .funct3(instr[14:12]),
    .op5(instr[5]),
    .funct7(instr[30]),
    .ALUControl(ALUControl)
);

//REGISTERS
REG_FILE reg_file_top(
    .clk(clk),
    .write_enable(RegWrite),
    .rs1(instr[19:15]),
    .rs2(instr[24:20]),
    .rd(instr[11:7]),
    .write_data(result),
    .RD1(RD1),
    .RD2(RD2)
);

assign A = RD1;

//EXTENDER
EXTENDER extender_top(
    .instr(instr),
    .immsrc(ImmSrc),
    .imm_ext(imm_ext)
);

//MUX para el ALUsrc
MUX alu_src_mux(
    .in0(RD2),
    .in1(imm_ext),
    .in2(0), //ignora este
    .in3(0), //ignora este
    .select(ALUSrc),
    .out(B)
);

//ALU
ALU alu_top(
    .A(A),
    .B(B),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult),
    .Zero(zero)
);

//DATA MEMORY
DATA_MEM dmem_top(
    .clk(clk),
    .addr(ALUResult),
    .WD(RD2),
    .WE(MemWrite),
    .RD(read_data)
);

//PROGRAM COUNTER MUX
MUX pc_mux(
    .in0(PC_plus),
    .in1(PC_target),
    .in2(0), //ignora este
    .in3(0), //ignora este
    .select(PCSrc),
    .out(PC_next)
);

//PC TARGET CALCULATOR
SUMADOR pc_target_calculator(
    .A(PC),
    .B(imm_ext),
    .result(PC_target)
);

//RESULT MUX
MUX result_mux(
    .in0(ALUResult),
    .in1(read_data),
    .in2(PC_plus),
    .in3(0), //ignora este 
    .select(ResultSrc),
    .out(result)
);

endmodule