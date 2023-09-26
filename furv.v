module furv(

    input [31:0] instruction,
    output reg [31:0] pc = 0,

    input [31:0] data_in,
    output reg [31:0] data_out,
    output reg [31:0] addr,
    output reg mem_en,
    output reg mem_read,

    input clk
);

integer i;

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
wire swap_imm_b;
wire wb;
wire branch;
wire unconditional_branch;
wire eq_compare;
wire inv_compare;

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
    .swap_imm_b(swap_imm_b),

    .wb(wb),
    .mem(decoder_mem_en),
    .mem_read(decoder_mem_read),

    .branch(branch),
    .unconditional_branch(unconditional_branch),
    .eq_compare(eq_compare),
    .inv_compare(inv_compare)
);

alu alu(
    .a(sel_pc_a ? pc : r[ra]),
    .b(swap_imm_b ? imm : r[rb]),

    .a2(r[ra]),
    .b2(!swap_imm_b ? imm : r[rb]),

    .d(alu_output),
    .d2(alu_output2),

    .alu_op(alu_op),
    .alu2_op(alu2_op),
    .alt_op(alt_op),
    .alt2_op(alt2_op)
);

wire cc = eq_compare ? r[ra] == r[rb] : alu_output2[0];
wire branch_taken = branch && (unconditional_branch || (cc ^ inv_compare));
wire [31:0] adjacent_pc = pc + 4;

always @(negedge clk) begin
    // $display("PC=%x A0=%x A1=%x A2=%x A3=%x ALU1_OP=%x", pc, r[10], r[11], r[12], r[13], alu_op);
    if (decoder_mem_en == mem_en) begin
        mem_en <= 0;

        if (rd != 0) begin
            if (unconditional_branch) begin
                r[rd] <= adjacent_pc;
            end else if (decoder_mem_en && decoder_mem_read) begin
                r[rd] <= data_in;
            end else begin
                r[rd] <= wb ? alu_output2 : alu_output;
            end
        end

        pc <= branch_taken ? alu_output : adjacent_pc;
    end else begin
        // Stall condition

        mem_en <= decoder_mem_en;
        mem_read <= decoder_mem_read;
        addr <= alu_output;

        if (decoder_mem_en && !decoder_mem_read) begin
            data_out <= r[rb];
        end
    end
end

endmodule
