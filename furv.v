module furv(
    input [31:0] instruction,
    output reg [31:0] pc,

    input [31:0] data_in,
    output reg [31:0] data_out,
    output reg [31:0] addr,
    output reg mem_read_out,
    output reg mem_out,

    input clk
);

integer i;

initial pc = 0;

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
wire [1:0] wb;
wire branch;
wire [2:0] comparison;

wire [31:0] alu_output;
wire [31:0] alu_output2;

wire mem_read;
wire mem;

reg[31:0] alu_a;
reg[31:0] alu_b;

reg[31:0] alu_a2;
reg[31:0] alu_b2;

immdecoder immdecoder(
    .instruction(instruction),
    .imm(imm)
);

decoder decoder(
    .instruction(instruction),

    .alu_op(alu_op),
    .alu2_op(alu2_op),
    .alt_op(alt_op),
    .alt2_op(alt2_op),

    .ra(ra),
    .rb(rb),
    .rd(rd),

    .sel_pc_a(sel_pc_a),
    .sel_imm_b(sel_imm_b),

    .wb(wb),
    .mem(mem),
    .mem_read(mem_read),

    .branch(branch),
    .comparison(comparison)
);

alu alu(
    .a(alu_a),
    .b(alu_b),

    .a2(alu_a2),
    .b2(alu_b2),

    .d(alu_output),
    .d2(alu_output2),

    .alu_op(alu_op),
    .alu2_op(alu2_op),
    .alt_op(alt_op),
    .alt2_op(alt2_op)
);

wire cc = !comparison[2] ? r[ra] == r[rb] : alu_output2[0];
wire branch_taken = branch && (cc ^ comparison[0]);
wire [31:0] adjacent_pc = pc + 4;

always @(posedge clk) begin
    alu_a <= sel_pc_a ? pc : r[ra];
    alu_b <= sel_imm_b ? imm : r[rb];

    alu_a2 <= r[ra];
    alu_b2 <= !sel_imm_b ? imm : r[rb];
end

always @(negedge clk) begin
    case (wb)
    1: r[rd] <= adjacent_pc;
    2: r[rd] <= alu_output;
    3: r[rd] <= alu_output2;
    endcase

    pc <= branch_taken ? alu_output : adjacent_pc;

    if (!mem) begin
        mem_out <= 0;
    end else begin
        mem_out <= mem;
        mem_read_out <= mem_read;

        if (!mem_read_out) begin
            data_out <= r[rb];
            addr <= alu_output;
        end
    end
end

endmodule
