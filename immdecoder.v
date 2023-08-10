module immdecoder(
    input [31:0] instruction,
    output reg [31:0] imm
);

wire j = instruction[3];
wire s = instruction[6:3] == 4'b0100;
wire b = instruction[6] && instruction[4:2] == 0;
wire u = instruction[4] && instruction[2];

(*onehot*)
wire jsbu = {j,s,b,u};

always @(*) begin
    imm[31] = instruction[31];

    case (u)
        0: imm[30:20] = {11{instruction[31]}};
        1: imm[30:20] = instruction[30:20];
    endcase

    case (u | j)
        0: imm[19:12] = {8{instruction[31]}};
        1: imm[19:12] = instruction[19:12];
    endcase

    case ({b | u, b | j})
        0: imm[11] = instruction[31];
        1: imm[11] = instruction[20];
        2: imm[11] = 0;
        3: imm[11] = instruction[7];
    endcase

    case (u)
        0: imm[10:5] = instruction[30:25];
        1: imm[10:5] = 0;
    endcase

    case ({s | b | u, u | j})
        0: imm[4:1] = instruction[24:21];
        1: imm[4:1] = instruction[24:21];
        2: imm[4:1] = instruction[11:8];
        3: imm[4:1] = 4'b0;
    endcase

    case ({s, b | u | j})
        0: imm[0] = instruction[20];
        1: imm[0] = 'b0;
        2: imm[0] = instruction[7];
        3: imm[0] = 'b0;
    endcase
end

endmodule
