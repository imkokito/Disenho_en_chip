// codigo para la ALU que hace operaciones 
module ALU (
    input [31:0] A, B, // recibe 2 entradas de 32 bits
    input [2:0] ALUControl, // y una señal de control para saber que hacer
    output reg [31:0] ALUResult, //para guardar el resultado de la operacion
    output reg Zero // y otra señal para saber si el ALUResult es 0
);

always @(*) begin
    case (ALUControl)
        3'b000: 
            ALUResult = A + B; //suma
        3'b001: 
            ALUResult = A - B;//resta
        3'b010: 
            ALUResult = A & B; //and
        3'b011: 
            ALUResult = A | B; //or
        3'b101: 
            ALUResult = (A < B) ? 1 : 0; //slt
        default: ALUResult = 0; //default para tener un valor seguro
    endcase

    Zero = (ALUResult == 0); //si alu es 0 se activa la señal del cero
end

endmodule
