module alu(
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] d,
    
    input [2:0] op
);

wire sub = op == 3'b100;
wire [31:0] b_ = sub ? ~b : b;
wire [31:0] c_ = sub ? 'b1 : 'b0;

always @* begin
    case (op[1:0])
        0: d = a + b_ + c_;
        1: d = a & b;
        2: d = a | b;
        3: d = a ^ b;
    endcase
end

endmodule
