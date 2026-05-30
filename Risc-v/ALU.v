module ALU (
    input [31:0] A, B,
    input [2:0] ALUControl,
    output reg [31:0] ALUResult,
    output reg Zero
);

always @(*) begin
    case (ALUControl)
        3'b000: 
            ALUResult = A + B;
        3'b001: 
            ALUResult = A - B;
        3'b010: 
            ALUResult = A & B;
        3'b011: 
            ALUResult = A | B;
        3'b101: 
            ALUResult = (A < B) ? 1 : 0;
        default: ALUResult = 0;
    endcase

    Zero = (ALUResult == 0);
end

endmodule