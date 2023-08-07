module furv(
    input [31:0] instruction,
    output reg [31:0] pc,

    inout [31:0] data,
    output [31:0] addr,
    output mem_read,
    output mem,

    input clk
);

integer i;

initial pc = 0;

assign data = (mem && !mem_read) ? r[rb] : 'hz;
assign addr = d;

reg [31:0] r [31:0];
initial for (i=0;i<32;i=i+1) r[i] = 32'b0;

wire [31:0] imm;
wire [1:0] alu_op;
wire alt_op;
wire [4:0] ra;
wire [4:0] rb;
wire [4:0] rd;
wire sel_imm_b;
wire wb;
wire branch;
wire [2:0] comparison;

wire [31:0] d;
wire [31:0] d_;

decoder decoder(
    .instruction(instruction),

    .alu_op(alu_op),
    .alt_op(alt_op),

    .ra(ra),
    .rb(rb),
    .rd(rd),

    .imm(imm),
    .sel_imm_b(sel_imm_b),

    .wb(wb),
    .mem(mem),
    .mem_read(mem_read),

    .branch(branch),
    .comparison(comparison)
);

alu alu(
    branch ? pc : r[ra],
    sel_imm_b ? imm : r[rb],
    d,
    d_,

    alu_op,
    alt_op
);

wire [1:0] cop = comparison[2:1];
wire cc = (cop == 0) ? r[ra] == r[rb]
        : (cop == 2) ? $signed(r[ra]) < $signed(r[rb])
        :              r[ra] < r[rb];
wire branch_taken = branch && (cc ^ comparison[0]);

always @(negedge clk) begin
    if (wb) begin
        r[rd] <= d;
    end

    pc <= branch_taken ? d : pc + 4;
end

endmodule
