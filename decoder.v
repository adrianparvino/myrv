module decoder(
    input [31:0] instruction,
    output reg [1:0] alu_op,
    output reg [1:0] alu2_op,
    output reg alt_op,
    output reg alt2_op,
    output reg [4:0] ra,
    output reg [4:0] rb,
    output reg [4:0] rd,
    output reg sel_pc_a,
    output reg swap_imm_b,
    output reg [1:0] wb,
    output reg mem_read,
    output reg mem,
    output reg branch,
    output reg unconditional_branch,
    output reg eq_compare,
    output reg inv_compare
);

function [1:0] alu_ops (input [2:0] funct3);
// 0: ADD
// 1: AND
// 2: XOR
// 3: OR
    alu_ops = {funct3[2], funct3[1] ^ funct3[0]};
endfunction

function [1:0] alu2_ops (input [2:0] funct3);
// 0: <<
// 1: <
// 2: >>
    alu2_ops = {funct3[2], funct3[1]};
endfunction

wire [7:0] lut = 8'b00101110;

function sel_d_ (input [2:0] funct3);
    sel_d_ = lut[funct3];
endfunction

wire [2:0] funct3 = instruction[14:12];

wire r = instruction[6:2] == 5'b01100;
wire jal = instruction[4:2] == 3'b011;
wire jalr = instruction[4:2] == 3'b001;
wire j = jal | jalr;
wire s = instruction[6:3] == 4'b0100;
wire b = instruction[6] && instruction[4:2] == 0;
wire u = instruction[4] && instruction[2];

// wire ri = {j,s,b,u} == 0;
wire alu1_en = {instruction[6], instruction[4:2]} == 4'b0100;

always @* begin
    mem = &(~{instruction[6], instruction[4:2]});
    mem_read = !instruction[5];
    ra = instruction[19:15];
    rb = instruction[24:20];
    rd = instruction[11:7];
    alu_op = alu1_en ? alu_ops(funct3) : 0;
    alt_op = r & instruction[30];
    alt2_op = alu1_en & instruction[30];
    sel_pc_a = jal | u | b;
    branch = j | b;
    unconditional_branch = j;
    eq_compare = !funct3[2];
    inv_compare = funct3[0];

    if (j) begin        // J-type
        alu2_op = 0;
        swap_imm_b = 1;
        wb = 1;
    end else if (u) begin        // U-type
        alu2_op = 3;
        swap_imm_b = !instruction[5];
        wb = {1'b1, instruction[5]}; // 1: lui, 0: auipc
    end else if (r) begin        // R-type
        alu2_op = alu2_ops(funct3);
        swap_imm_b = sel_d_(funct3);
        wb = {1'b1, sel_d_(funct3)};
    end else if (s) begin        // S-type
        alu2_op = 0;
        swap_imm_b = 1;
        wb = 0;
    end else if (b) begin        // B-type
        alu2_op = 1; // Comparison
        swap_imm_b = 1;
        wb = 0;
    end else begin        // I-type
        alu2_op = alu2_ops(funct3);
        swap_imm_b = instruction[6:2] == 5'b0 | !sel_d_(funct3);
        wb = {1'b1, sel_d_(funct3)};
    end
end

endmodule
