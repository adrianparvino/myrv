module immdecoder(
    input [31:0] instruction,
    output reg [31:0] imm
);

wire j = instruction[3];
wire s = instruction[6:3] == 4'b0100;
wire b = instruction[6] && instruction[4:2] == 0;
wire u = instruction[4] && instruction[2];

always @(*) begin
    imm[31] = instruction[31];

    case (u)
        0: imm[30:20] = {11{instruction[31]}};
        1: imm[30:20] = instruction[30:20]; // U
    endcase

    case (u | j)
        0: imm[19:12] = {8{instruction[31]}};
        1: imm[19:12] = instruction[19:12]; // U | J
    endcase

    case ({b | u, b | j})
        0: imm[11] = instruction[31]; // S | I
        1: imm[11] = instruction[20]; // J
        2: imm[11] = 0; // U
        3: imm[11] = instruction[7]; // B
    endcase

    case (u)
        0: imm[10:5] = instruction[30:25];
        1: imm[10:5] = 0; // U
    endcase

    case ({s | b | u, u | j})
        0: imm[4:1] = instruction[24:21]; // I
        1: imm[4:1] = instruction[24:21]; // J
        2: imm[4:1] = instruction[11:8]; // S | B
        3: imm[4:1] = 4'b0; // U
    endcase

    case ({s, b | u | j})
        0: imm[0] = instruction[20]; // I
        1: imm[0] = 'b0; // B | U | J
        2: imm[0] = instruction[7]; // S
        3: imm[0] = 'b0; // UNREACHABLE
    endcase
end

endmodule
