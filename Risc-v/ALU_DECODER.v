//codigo para decodificar la ALU para saber que hacer depediendo de la instrucción
module ALU_DECODER(
    input [1:0] ALUOp, //recibe ALUop que tiene el codigo general de la instruccion
    input [2:0] funct3, //funct3, funct7 y op5 ayuda a diferenciar que tipo de instruccion vamos a hacer
    input op5,
    input funct7,
    output reg [2:0] ALUControl //aqui se guarda la decodificacion para que la ALU sepa que hacer
);

always @(*) begin
    case(ALUOp)

        2'b00: //se puede usar para sumarle cosas al program counter para calcular direcciones
            ALUControl = 3'b000; // lw/sw -> add
        2'b01: //se puede usar para comparar los resultados de restas para saber si la señal de zero se activa
            ALUControl = 3'b001; // beq -> sub
        2'b10: begin
            case(funct3) //usamos funct 3 y en algunos casos funct7 y op5 para diferenciar entre instrucciones
                3'b000: begin
                    if (op5 && funct7)
                        ALUControl = 3'b001; // sub
                    else
                        ALUControl = 3'b000; // add/addi
                end
                3'b010: 
                    ALUControl = 3'b101; // slt
                3'b110: 
                    ALUControl = 3'b011; // or
                3'b111: 
                    ALUControl = 3'b010; // and
                default: 
                    ALUControl = 3'b000;
            endcase
        end
        default: 
            ALUControl = 3'b000;
    endcase
end


endmodule
