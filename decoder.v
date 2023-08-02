module decoder(
    input [31:0] instruction,
    output reg [31:0] imm,
    output reg [2:0] op,
    output reg [4:0] ra,
    output reg [4:0] rb,
    output reg [4:0] rd,
    output reg imm_b,
    output reg wb,
    output reg mem_read,
    output reg mem,
    output reg branch,
    output reg [2:0] comparison
);

wire [6:0] opcode = instruction[6:0];
wire [2:0] funct3 = instruction[14:12];
wire [6:0] funct7 = instruction[31:25];

wire [2:0] ops [7:0][127:0];
assign ops[3'h0][7'h0] = 3'b0;
assign ops[3'h0][7'h20] = 3'b100;

always @(*) begin
    if (opcode == 7'b0110011) begin
        // R-type
        imm = 32'b0;
        op = ops[funct3][funct7];
        ra = instruction[19:15];
        rb = instruction[24:20];
        rd = instruction[11:7];
        imm_b = 0;
        wb = rd != 0;
        mem_read = 0;
        mem = 0;
        branch = 0;
        comparison = 3'b0;
    end else if (opcode == 7'b0010011) begin
        // I-type
        imm = {{21{instruction[31]}}, instruction[30:20]};
        op = ops[funct3][7'b0];
        ra = instruction[19:15];
        rb = 5'b0;
        rd = instruction[11:7];
        imm_b = 1;
        wb = rd != 0;
        mem_read = 0;
        mem = 0;
        branch = 0;
        comparison = 3'b0;
    end else if (opcode == 7'b0100011) begin
        // S-type
        imm = {{21{instruction[31]}}, instruction[30:25], instruction[11:8], instruction[7]};
        op = 3'b0;
        ra = instruction[19:15];
        rb = instruction[24:20];
        rd = 5'b0;
        imm_b = 1;
        wb = 0;
        mem_read = 0;
        mem = 1;
        branch = 0;
        comparison = 3'b0;
    end else if (opcode == 7'b1100011) begin
        // B-type
        imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        op = 3'b0;
        ra = instruction[19:15];
        rb = instruction[24:20];
        rd = 5'b0;
        imm_b = 1;
        wb = 0;
        mem_read = 0;
        mem = 1;
        branch = 1;
        comparison = funct3;
    end else begin
        // undefined
        imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        op = 3'b0;
        ra = instruction[19:15];
        rb = instruction[24:20];
        rd = 5'b0;
        imm_b = 1;
        wb = 0;
        mem_read = 0;
        mem = 1;
        branch = 1;
        comparison = funct3;
      end
end
    
endmodule
