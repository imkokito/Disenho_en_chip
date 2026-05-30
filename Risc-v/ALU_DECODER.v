module ALU_DECODER(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input op5,
    input funct7,
    output reg [2:0] ALUControl
);

always @(*) begin
    case(ALUOp)

        2'b00: 
            ALUControl = 3'b000; // lw/sw -> add
        2'b01: 
            ALUControl = 3'b001; // beq -> sub
        2'b10: begin
            case(funct3)
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