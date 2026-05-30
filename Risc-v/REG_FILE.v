module REG_FILE(
    input clk, write_enable,
    input [4:0] rs1, rs2, rd,
    input [31:0] write_data,
    output reg [31:0] RD1, RD2
);

reg [31:0] register [31:0]; 


always @(*)
begin
    if (rs1 == 0)
        RD1 = 0;
    else
        RD1 = register[rs1];

    if (rs2 == 0)
        RD2 = 0;
    else
        RD2 = register[rs2];
end

always @(posedge clk)
begin
    if (write_enable == 1 && rd != 0)
        register[rd] <= write_data;
end

endmodule