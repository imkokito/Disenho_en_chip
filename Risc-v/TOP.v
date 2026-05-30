//codigo del módulo principal del procesador RISC-V single-cycle.
//aqui se conectan todos los bloques del procesador:
module TOP(
    input clk,
    input rst
);

//señales relacionadas con el Program Counter
wire [31:0] PC;         //Valor actual del PC
wire [31:0] PC_next;    
wire [31:0] PC_plus;    //Valor del PC, para la siguiente instrucción
wire [31:0] PC_target;  // Dirección a donde saltar

//instrucción leída de la memoria de instrucciones
wire [31:0] instr;

//salidas del banco de registros
wire [31:0] RD1;        //dato del registro rs1
wire [31:0] RD2;        //dato del registro rs2

//entradas de la ALU
wire [31:0] A;         
wire [31:0] B;         

//resultado de la ALU
wire [31:0] ALUResult;

//inmediato extendido por el EXTENDER
wire [31:0] imm_ext;

//dato leído desde la memoria de datos
wire [31:0] read_data;

//dato que se escribe en los registros
wire [31:0] result;

//señal del Zero generada por la ALU.
wire zero;

// Señales de control del MAIN_DECODER y el ALU_DECODER
wire PCSrc;             //dice si el siguiente PC es PC+4 o PC_target
wire [1:0] ResultSrc;   //dice si lo que se escribe en rd viene de la ALU o de la memoria
wire MemWrite;          //hablita escribir en la memoria
wire ALUSrc;            //dice si el segundo factor viene del registro o del inmediato
wire RegWrite;          //habilita escribir en el registro destino
wire [1:0] ALUOp;       //operacion que tiene que hacer la ALU
wire [1:0] ImmSrc;      //dice que inmediato generar
wire [2:0] ALUControl;  //codigo que recibe la ALU desde el ALU_DECODER, es lo de ALUOp

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
