`timescale 1ns / 1ps
module meow;

reg [31:0] rom[15:0];
wire [31:0] pc;

wire [31:0] data;
wire [31:0] addr;
wire mem_read;
wire mem;

reg clk;

furv core(rom[pc >> 2], pc, data, addr, mem_read, mem, clk);

initial begin
    #5 clk = 0;
    forever
        #5 clk = ~clk;
end

integer i;
initial begin
    rom[0] = 32'h40000113; // li	sp,1024
    rom[1] = 32'h01000193; // li	gp,16
    rom[2] = 32'h00110023; // sb	ra,0(sp)
    rom[3] = 32'h00108093; // add	ra,ra,1
    rom[4] = 32'hfe309ce3; // bne	ra,gp,8 <.L1^B1>

    // rom[0] = 32'h40010113;
    // rom[1] = 32'h00110023;
    
    // for (i=2;i<=12;i=i+2) begin
    //     rom[i] <= 32'h00108093;
    //     rom[i+1] <= 32'h00110023;
    // end

    // rom[14] <= 32'h401080b3;
    // rom[15] <= 32'h00100023;
end

initial #10000000 $finish;

initial begin
end

always @(posedge(clk)) begin
    if (mem) begin
        if (!mem_read) begin
            if (addr == 1024) begin
                $display ("data=%b, addr=%b", data, addr); 
            end
        end
    end
end

endmodule
