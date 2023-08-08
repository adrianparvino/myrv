module alu(
    input [31:0] a,
    input [31:0] b,

    input [31:0] a2,
    input [31:0] b2,

    output reg [31:0] d,
    output reg [31:0] d2,
    
    input [1:0] alu_op,
    input [1:0] alu2_op,
    input alt_op,
    input alt2_op
);

wire [31:0] b_ = alt_op ? ~b : b;
wire [31:0] c_ = alt_op ? 'b1 : 'b0;

wire [31:0] signed_bias = alt2_op ? 32'h80000000 : 0;
reg [31:0] ignore;

always @* begin
    case (alu_op)
        0: d = a + b_ + c_;
        1: d = a & b_;
        2: d = a ^ b_;
        3: d = a | b_;
    endcase
end

always @* begin
    case (alu2_op)
        0: d2 = a2 << b2[4:0];
        1: d2 = {31'b0, (signed_bias ^ a2) < (signed_bias ^ b2)};
        2: {ignore, d2} = {{32{alt2_op & a2[31]}}, a2} >> b2[4:0];
        3: d2 = b2;
    endcase
end

endmodule
