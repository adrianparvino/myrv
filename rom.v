module rom(
  input [31:0] pc,
  output [31:0] instruction
);

reg [7:0] code[255:0];

initial $readmemh("firmware", code, 0, 255);
assign instruction = { code[pc + 3], code[pc + 2], code[pc + 1], code[pc] };

endmodule
