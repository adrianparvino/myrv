module alu(
    input [31:0] a,
    input [31:0] b,
    output [31:0] d,
    
    input [2:0] op
);

wire sub = op == 3'b100;
wire [31:0] b_ = !sub ? b : ~b;
assign d = a + b_ + (sub ? 'b1 : 'b0);

endmodule
