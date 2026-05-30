//codigo para la memoria de datos
//sirve para leer o escribir los datos 
module DATA_MEM(
    input clk,
    input WE, //señal para escribir
    input [31:0] addr, WD, //el dato y la direccion de donde escribir o leer
    output [31:0] RD //el dato
);

reg [31:0] memory [0:255]; //vector de 256 palabras de 32 bits cada una

integer i;

initial begin //inicializar en 0 para no tener datos basura
    for (i=0; i<256; i=i+1) begin
        memory[i]=0; 
    end
end

always @(posedge clk) begin //se escribe el dato si WE=1 usando addr[31:2] porque la memoria se direcciona por palabras
    if (WE) begin
        memory[addr[31:2]] <= WD; 
    end
end

assign RD = memory[addr[31:2]]; 

endmodule
