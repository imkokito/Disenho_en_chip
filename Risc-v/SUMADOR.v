// codigo para poder sumarle cosas al program counter
module SUMADOR(
    input [31:0] A, B, // 2 inputs de 32 bits 
    output [31:0] result // 1 output también de 32 bits
);

assign result = A + B; // asignar el resultado de la suma a la variable de salida

endmodule
