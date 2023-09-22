(* top *)
module top(
    input clk,
    output reg [5:0] led
);

wire [31:0] pc;
wire [31:0] instruction;

wire [31:0] data_in;
wire [31:0] data_out;
wire [31:0] addr;

wire mem_read;
wire mem_en;

reg [21:0] counter = 0;

initial begin
    led[5:0] = 6'b111111;
end

rom rom(pc, instruction);

furv furv(
    .instruction(instruction),
    .pc(pc),
    .data_in(data_in),
    .data_out(data_out),
    .addr(addr),
    .mem_read(mem_read),
    .mem_en(mem_en),
    .clk(counter[21])
);

always @(posedge clk) begin
    counter <= counter + 1;
end

always @(negedge counter[21]) begin
    if (mem_en && !mem_read && addr == 1024) begin
        led[4:0] <= ~data_out[4:0];
    end
end

endmodule
