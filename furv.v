module furv(
    input [31:0] instruction, 
    output reg [31:0] pc,

    inout [31:0] data,
    output [31:0] addr,
    output mem_read,
    output mem,

    input clk
);

initial pc = 0;

assign data = r[rb];
assign addr = d;

reg [31:0] r [31:0];
integer i;
initial begin
    for (i=0;i<32;i=i+1)
        r[i] = 32'b0;

    r[1] = 32'b1;
end

wire [31:0] imm;
wire [2:0] op;
wire [4:0] ra;
wire [4:0] rb;
wire [4:0] rd;
wire imm_b;
wire wb;
wire branch;
wire [2:0] comparison;

wire [31:0] d;

decoder decoder(instruction, imm, op, ra, rb, rd, imm_b, wb, mem_read, mem, branch, comparison);
alu alu(branch ? pc : r[ra], imm_b ? imm : r[rb], d, op);

wire [1:0] cop = comparison[2:1];
wire cc = (cop == 0) ? r[ra] == r[rb]
        : (cop == 2) ? $signed(r[ra]) < $signed(r[rb])
        :              r[ra] < r[rb];

always @(negedge clk) begin
    if (wb) begin
        r[rd] = d;
    end

    pc = (branch && (cc ^ comparison[0])) ? d : pc + 4;
end

endmodule
