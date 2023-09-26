module decoder(
    input [31:0] instruction,
    output [1:0] alu_op,
    output reg [1:0] alu2_op,
    output alt_op,
    output alt2_op,
    output [4:0] ra,
    output [4:0] rb,
    output [4:0] rd,
    output sel_pc_a,
    output swap_imm_b,
    output reg wb,
    output mem_read,
    output mem,
    output branch,
    output unconditional_branch,
    output eq_compare,
    output inv_compare
);

function [1:0] alu_ops (input [2:0] funct3);
// 0: ADD
// 1: AND
// 2: XOR
// 3: OR
    alu_ops = {funct3[2] ^ funct3[0], funct3[1]};
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
wire j = instruction[6] && instruction[2];
wire s = instruction[6:3] == 4'b0100;
wire b = instruction[6] && instruction[4:2] == 0;
wire u = instruction[4] && instruction[2];

wire alu1_en = {instruction[6], instruction[4:2]} == 4'b0100;
wire [15:0] swap_lut = 16'b0010111111010011;

assign ra = instruction[19:15];
assign rb = instruction[24:20];
assign rd = instruction[11:7];

assign mem = &(~{instruction[6], instruction[4:2]});
assign mem_read = !instruction[5];

assign alu_op = alu1_en ? alu_ops(funct3) : 0;
assign alt_op = r & instruction[30];
assign alt2_op = alu1_en & instruction[30];
assign sel_pc_a = instruction[6] ^ instruction[3] ^ instruction[2];
assign branch = j | b;
assign unconditional_branch = j;
assign eq_compare = !funct3[2];
assign inv_compare = funct3[0];
assign swap_imm_b = swap_lut[{instruction[5:4], instruction[2], sel_d_(funct3)}];

always @* begin
    if (j) begin        // J-type
        alu2_op = 0;
        wb = 1;
    end else if (u) begin        // U-type
        alu2_op = 3;
        wb = instruction[5]; // 1: lui, 0: auipc
    end else if (r) begin        // R-type
        alu2_op = alu2_ops(funct3);
        wb = sel_d_(funct3);
    end else if (s) begin        // S-type
        alu2_op = 0;
        wb = 0;
    end else if (b) begin        // B-type
        alu2_op = 1; // Comparison
        wb = 0;
    end else begin        // I-type
        alu2_op = alu2_ops(funct3);
        wb = sel_d_(funct3);
    end
end

endmodule
