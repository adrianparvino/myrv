module alu(
    input [31:0] a,
    input [31:0] b,
    output [31:0] d,
    input cin,
    output cout,
    
    input [2:0] op
);

wire invert_b_cin = op == 3'b100;

wire [31:0] b_ = b ^ {32{invert_b_cin}};
wire cin_ = cin ^ invert_b_cin;
wire [32:0] sum = a + b_ + (cin_ ? 'b1 : 'b0);

assign d = sum[31:0];
assign cout = (op == 0) & sum[32];

endmodule
