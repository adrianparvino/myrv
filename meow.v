`timescale 1ns / 1ps
module meow;

reg clk;

wire [31:0] instruction;
wire [31:0] pc;

wire [31:0] data_in = ram_select ? ram_out : 0;
wire [31:0] data_out;
wire [31:0] addr;

wire [31:0] ram_out;

wire mem_read;
wire mem_en;

wire ram_select = 256 <= addr && addr < 256 + 256;
wire led_select = addr == 1024;

rom rom(pc, instruction);

wire read_ack;

ram ram(
    .read_addr(addr[7:2]),
    .data_out(data_in),
    .mem_read(mem_en && mem_read && ram_select),
    .read_ack(read_ack),
    .read_clk(clk),

    .write_addr(addr[7:2]),
    .data_in(data_out),
    .mem_write(mem_en && !mem_read && ram_select),
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
    .read_ack(read_ack),

    .clk(clk)
);

initial begin
    #5 clk = 0;
    forever
        #5 clk = ~clk;
end

initial #1000000 $finish;

initial begin
end

always @(posedge(clk)) begin
    if (mem && !mem_read && led_select) begin
        $display ("data_out=%b, addr=%b", data_out, addr); 
    end
end

endmodule
