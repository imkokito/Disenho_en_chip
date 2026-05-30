module DATA_MEM(
    input clk,
    input WE,
    input [31:0] addr, WD,
    output [31:0] RD
);

reg [31:0] memory [0:255]; //vector de 256 palabras de 32 bits cada una

integer i;

initial begin
    for (i=0; i<256; i=i+1) begin
        memory[i]=0; 
    end
end

always @(posedge clk) begin
    if (WE) begin
        memory[addr[31:2]] <= WD; 
    end
end

assign RD = memory[addr[31:2]]; 

endmodule