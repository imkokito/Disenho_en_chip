module PROGRAM_COUNTER(
    input clk,
    input rst,
    input [31:0] PC_next,
    output reg [31:0] PC
);

always @(posedge clk or posedge rst) begin
    if (rst)
        PC <= 0; //reinicia a 0
    else 
        PC <= PC_next; // le da el siguiente valor a PC, en el top va a ser lo de si suma 4 o es normalito
    
end
endmodule