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

reg ignore;

wire [31:0] arith_result = alt_op ? a - b : a + b;

always @* begin
    case (alu_op)
        0: d = alt_op ? a - b : a + b;
        1: d = a & b;
        2: d = a ^ b;
        3: d = a | b;
    endcase

    case (alu2_op)
        0: d2 = a2 << b2[4:0];
        1: d2 = {31'b0, ({alt2_op ^ a2[31], a2[30:0]} < {alt2_op ^ b2[31], b2[30:0]})};
        2: {ignore, d2} = {alt2_op & a2[31], a2} >>> b2[4:0];
        3: d2 = b2;
    endcase
end

endmodule
