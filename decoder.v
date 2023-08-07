module decoder(
    input [31:0] instruction,
    output reg [31:0] imm,
    output reg [1:0] alu_op,
    output reg alt_op,
    output reg [4:0] ra,
    output reg [4:0] rb,
    output reg [4:0] rd,
    output reg sel_imm_b,
    output reg wb,
    output reg mem_read,
    output reg mem,
    output reg branch,
    output reg [2:0] comparison
);

wire [6:0] opcode = instruction[6:0];
wire [2:0] funct3 = instruction[14:12];
wire [6:0] funct7 = instruction[31:25];

wire [1:0] alu_ops [7:0];
assign alu_ops[3'h0] = 2'h0;
assign alu_ops[3'h7] = 2'h1;
assign alu_ops[3'h6] = 2'h2;
assign alu_ops[3'h4] = 2'h3;

always @(*) begin
    if (opcode == 7'b0110011) begin
        // R-type
        imm = 32'b0;
        alu_op = alu_ops[funct3];
        alt_op = funct7 == 'h20;
        ra = instruction[19:15];
        rb = instruction[24:20];
        rd = instruction[11:7];
        sel_imm_b = 0;
        wb = rd != 0;
        mem_read = 0;
        mem = 0;
        branch = 0;
        comparison = 3'b0;
    end else if (opcode == 7'b0010011) begin
        // I-type
        imm = {{21{instruction[31]}}, instruction[30:20]};
        alu_op = alu_ops[funct3];
        alt_op = 0;
        ra = instruction[19:15];
        rb = 5'b0;
        rd = instruction[11:7];
        sel_imm_b = 1;
        wb = rd != 0;
        mem_read = 0;
        mem = 0;
        branch = 0;
        comparison = 3'b0;
    end else if (opcode == 7'b0100011) begin
        // S-type
        imm = {{21{instruction[31]}}, instruction[30:25], instruction[11:8], instruction[7]};
        alu_op = 2'b0;
        alt_op = 0;
        ra = instruction[19:15];
        rb = instruction[24:20];
        rd = 5'b0;
        sel_imm_b = 1;
        wb = 0;
        mem_read = 0;
        mem = 1;
        branch = 0;
        comparison = 3'b0;
    end else if (opcode == 7'b1100011) begin
        // B-type
        imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        alu_op = 2'b0;
        alt_op = 0;
        ra = instruction[19:15];
        rb = instruction[24:20];
        rd = 5'b0;
        sel_imm_b = 1;
        wb = 0;
        mem_read = 0;
        mem = 1;
        branch = 1;
        comparison = funct3;
    end else begin
        // undefined
        imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        alu_op = 2'b0;
        alt_op = 0;
        ra = instruction[19:15];
        rb = instruction[24:20];
        rd = 5'b0;
        sel_imm_b = 1;
        wb = 0;
        mem_read = 0;
        mem = 1;
        branch = 1;
        comparison = funct3;
      end
end
    
endmodule
