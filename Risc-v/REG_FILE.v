//código para los registros, lee los registros y en caso de necesitarlo escribe en ellos
module REG_FILE(
    input clk, write_enable, //clk y señal para habiliar que escriba
    input [4:0] rs1, rs2, rd, //registros fuente y destino
    input [31:0] write_data, //dato a escribir
    output reg [31:0] RD1, RD2 //datos leidos 
);

reg [31:0] register [31:0]; //vector de registros


always @(*)
begin
    if (rs1 == 0)
        RD1 = 0; 
    else
        RD1 = register[rs1]; //si el registro fuente no es 0 devuelve el valor

    if (rs2 == 0)
        RD2 = 0;
    else
        RD2 = register[rs2];
end

//si la señal de escribir se activa y el registro no es 0, se escribe el dato 
always @(posedge clk)
begin
    if (write_enable == 1 && rd != 0)
        register[rd] <= write_data;
end

endmodule
