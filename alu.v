module alu(
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] d,
    output reg [31:0] d_,
    
    input [1:0] alu_op,
    input alt_op
);

wire [31:0] b_ = alt_op ? ~b : b;
wire [31:0] c_ = alt_op ? 'b1 : 'b0;

always @* begin
    case (alu_op)
        0: d = a + b_ + c_;
        1: d = a & b;
        2: d = a | b;
        3: d = a ^ b;
    endcase
end

endmodule
