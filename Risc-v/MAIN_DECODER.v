//código para la unidad principal de las señales de control
//recibe lo de la instrucción y genera las señales de control para poder controlar el camino que toman los datos
module MAIN_DECODER (
    input [6:0] opcode, //recibe el opcode de la instrucción que vamos a hacer y la señal del zero
    input zero,
    output reg PC_src, //manda las señales de control para el PC, la memoria, ALU, escribir registros, etc
    output reg [1:0] Result_src,
    output reg mem_write,
    output reg ALU_src,
    output reg Reg_write,
    output reg branch,
    output reg [1:0] ALU_op,
    output reg [1:0] imm_src
);


always @(*) begin
    case (opcode) 
        7'b0000011: begin // I_type (3)
            PC_src = 0;
            Result_src = 0;
            mem_write = 0;
            ALU_src = 1;
            Reg_write = 1;
            branch = 0;
            ALU_op = 2'b00;
            imm_src = 2'b00;
        end
        7'b0010011: begin // I-type addi
            PC_src = 0;
            Result_src = 0;
            mem_write = 0;
            ALU_src = 1;
            Reg_write = 1;
            branch = 0;
            ALU_op = 2'b10;
            imm_src = 2'b00;
        end
        7'b0100011: begin // s_type (35)
            PC_src = 0;
            Result_src = 2'bxx; //no importa
            mem_write = 1;
            ALU_src = 1;
            Reg_write = 0;
            branch = 0;
            ALU_op = 2'b00;
            imm_src = 2'b01;
        end
        7'b0110011: begin // R_type (51)
            PC_src = 0;
            Result_src = 0;
            mem_write = 0;
            ALU_src = 0;
            Reg_write = 1;
            branch = 0;
            ALU_op = 2'b10;
            imm_src = 2'bxx; //no importa
        end
        7'b1100011: begin // B_type (99)
            PC_src = zero; // Si zero es 1, entonces se toma esa ruta, si es 0, se sigue con la siguiente instrucción
            Result_src = 2'bxx; //no importa
            mem_write = 0;
            ALU_src = 0;
            Reg_write = 0;
            branch = 1;
            ALU_op = 2'b01;
            imm_src = 2'b10;
        end
        7'b1101111: begin // J_type (111)
            PC_src = 1;
            Result_src = 2'b10; // PC + 4
            mem_write = 0;
            ALU_src = 0;
            Reg_write = 1;
            branch = 0;
            ALU_op = 2'bxx; //no importa
            imm_src = 2'b11;
        end
        default: begin
            PC_src = 0;
            Result_src = 0;
            mem_write = 0;
            ALU_src = 0;
            Reg_write = 0;
            branch = 0;
            ALU_op = 2'b00;
            imm_src = 2'b00;
        end
    endcase
end
endmodule 



