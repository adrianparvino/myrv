module rom(
  input [31:0] pc,
  output [31:0] instruction
);

reg [31:0] code[15:0];

initial begin
    code[0] = 32'h40000113; // li	sp,1024
    code[1] = 32'h01000193; // li	gp,16
    code[2] = 32'h00108093; // add	ra,ra,1
    code[3] = 32'h00110023; // sb	ra,0(sp)
    code[4] = 32'hfe309ce3; // bne	ra,gp,8 <.L1^B1>
    code[5] = 32'h0000006f; // halt
end

// initial begin
//     rom[0] = 32'h40000113; // li	sp,1024
//     rom[1] = 32'h01000193; // li	gp,16
//     rom[2] = 32'h00108093; // add	ra,ra,1
//     rom[3] = 32'h00110023; // sb	ra,0(sp)
//     rom[4] = 32'hfe309ce3; // bne	ra,gp,8 <.L1^B1>
//     rom[5] = 32'h0000006f; // halt

//     // rom[0] = 32'h40010113;
//     // rom[1] = 32'h00110023;
    
//     // for (i=2;i<=12;i=i+2) begin
//     //     rom[i] <= 32'h00108093;
//     //     rom[i+1] <= 32'h00110023;
//     // end

//     // rom[14] <= 32'h401080b3;
//     // rom[15] <= 32'h00100023;
// end

assign instruction = code[pc >> 2];

endmodule
