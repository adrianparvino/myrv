module furv(
    input [31:0] instruction,
    output reg [31:0] pc,

    input [31:0] data_in,
    output reg [31:0] data_out,
    output reg [31:0] addr,
    output reg mem_en,
    output reg mem_read,

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

wire decoder_mem_en;
wire decoder_mem_read;

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
    .mem(decoder_mem_en),
    .mem_read(decoder_mem_read),

    .branch(branch),
    .comparison(comparison)
);

alu alu(
    .a(sel_pc_a ? pc : r[ra]),
    .b(sel_imm_b ? imm : r[rb]),

    .a2(r[ra]),
    .b2(!sel_imm_b ? imm : r[rb]),

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

always @(negedge clk) begin
    case (wb)
    1: r[rd] <= adjacent_pc;
    2: r[rd] <= alu_output;
    3: r[rd] <= alu_output2;
    endcase

    pc <= branch_taken ? alu_output : adjacent_pc;

    if (decoder_mem_en) begin
        mem_en <= 1'b1;
        mem_read <= decoder_mem_read;
    end else begin
        mem_en <= 1'b0;
        mem_read <= decoder_mem_read;
    end

    if (decoder_mem_en && !decoder_mem_read) begin
        data_out <= r[rb];
        addr <= alu_output;
    end
end

endmodule
