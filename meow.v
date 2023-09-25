`timescale 1ns / 1ps
module meow;

wire [31:0] instruction;
wire [31:0] pc;

wire [31:0] data_in;
wire [31:0] data_out;
wire [31:0] addr;
wire mem_read;
wire mem;

reg clk;

rom rom(pc, instruction);

ram ram(
    .read_addr(addr[7:0]),
    .write_addr(addr[7:0]),
    .data_in(data_out),
    .data_out(data_in),
    .mem_read(mem && mem_read),
    .mem_write(mem && !mem_read),
    .read_clk(clk),
    .write_clk(clk)
);

furv core(
    .instruction(instruction), 
    .pc(pc), 

    .data_in(data_in), 
    .data_out(data_out), 
    .addr(addr), 
    .mem_en(mem), 
    .mem_read(mem_read), 

    .clk(clk)
);

initial begin
    #5 clk = 0;
    forever
        #5 clk = ~clk;
end

initial #10000 $finish;

initial begin
end

always @(posedge(clk)) begin
    if (mem) begin
        if (!mem_read) begin
            if (addr == 1024) begin
                $display ("data_out=%b, addr=%b", data_out, addr); 
            end
        end
    end
end

endmodule
