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
wire [1:0] alu2_op;
wire alt_op;
wire alt2_op;
wire [4:0] ra;
wire [4:0] rb;
wire [4:0] rd;
wire sel_pc_a;
wire sel_imm_b;
wire sel_imm_b2;
wire [1:0] wb;
wire branch;
wire [2:0] comparison;

wire [31:0] d;
wire [31:0] d2;

decoder decoder(
    .instruction(instruction),

    .alu_op(alu_op),
    .alu2_op(alu2_op),
    .alt_op(alt_op),
    .alt2_op(alt2_op),

    .ra(ra),
    .rb(rb),
    .rd(rd),

    .imm(imm),
    .sel_pc_a(sel_pc_a),
    .sel_imm_b(sel_imm_b),
    .sel_imm_b2(sel_imm_b2),

    .wb(wb),
    .mem(mem),
    .mem_read(mem_read),

    .branch(branch),
    .comparison(comparison)
);

alu alu(
    sel_pc_a ? pc : r[ra],
    sel_imm_b ? imm : r[rb],

    r[ra],
    sel_imm_b2 ? imm : r[rb],

    d,
    d2,

    alu_op,
    alu2_op,
    alt_op,
    alt2_op
);

wire cc = !comparison[2] ? r[ra] == r[rb] : d2[0];
wire branch_taken = branch && (cc ^ comparison[0]);
wire [31:0] adjacent_pc = pc + 4;

always @(negedge clk) begin
    case (wb)
    1: r[rd] <= adjacent_pc;
    2: r[rd] <= d;
    3: r[rd] <= d2;
    endcase

    pc <= branch_taken ? d : adjacent_pc;
end

endmodule
