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
    output reg sel_imm_b,
    output reg [1:0] wb,
    output reg mem_read,
    output reg mem,
    output reg branch,
    output reg [2:0] comparison
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

reg sel_d_ [7:0]; initial begin
    sel_d_[3'b000] = 0;
    sel_d_[3'b001] = 1;
    sel_d_[3'b010] = 1;
    sel_d_[3'b011] = 1;
    sel_d_[3'b100] = 0;
    sel_d_[3'b101] = 1;
    sel_d_[3'b110] = 0;
    sel_d_[3'b111] = 0;
end

wire [2:0] funct3 = instruction[14:12];
wire [6:0] funct7 = instruction[31:25];

wire r = instruction[6:2] == 5'b01100;
wire j = instruction[3];
wire s = instruction[6:3] == 4'b0100;
wire b = instruction[6] && instruction[4:2] == 0;
wire u = instruction[4] && instruction[2];

wire ri = {j,s,b,u} == 0;

always @(*) begin 
    mem = &(~{instruction[6], instruction[4:2]});
    mem_read = !instruction[5];
    ra = instruction[19:15];
    rb = instruction[24:20];
    rd = instruction[11:7];
    alu_op = ri ? alu_ops(funct3) : 0;
    alt_op = r && funct7 == 'h20;
    sel_pc_a = j | u | b;

    if (j) begin        // J-type
        alu2_op = 0;
        alt2_op = 0;
        sel_imm_b = 1;
        wb = rd != 0 ? 1 : 0;
        branch = 1;
        comparison = 0;
    end else if (u) begin        // U-type
        alu2_op = 3;
        alt2_op = 0;
        sel_imm_b = !instruction[5];
        wb = rd != 0 ? {1'b1, instruction[5]} : 0; // 1: lui, 0: auipc
        branch = 0;
        comparison = 0;
    end else if (r) begin        // R-type
        alu2_op = alu2_ops(funct3);
        alt2_op = funct7 == 'h20;
        sel_imm_b = sel_d_[funct3];
        wb = rd != 0 ? {1'b1, sel_d_[funct3]} : 0;
        branch = 0;
        comparison = 3'b0;
    end else if (s) begin        // S-type
        alu2_op = 0;
        alt2_op = 0;
        sel_imm_b = 1;
        wb = 0;
        branch = 0;
        comparison = 3'b0;
    end else if (b) begin        // B-type
        alu2_op = 1; // Comparison
        alt2_op = 0;
        sel_imm_b = 1;
        wb = 0;
        branch = 1;
        comparison = funct3;
    end else begin        // I-type
        alu2_op = alu2_ops(funct3);
        alt2_op = instruction[30];
        sel_imm_b = !sel_d_[funct3];
        wb = rd != 0 ? {1'b1, sel_d_[funct3]} : 0;
        branch = 0;
        comparison = 3'b0;
    end
end

endmodule
