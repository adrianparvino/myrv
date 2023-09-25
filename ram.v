module ram(
    input [7:0] read_addr,
    input [7:0] write_addr,
    input [31:0] data_in,
    output reg [31:0] data_out = 0,
    input mem_read,
    input mem_write,
    input read_clk,
    input write_clk
);

integer i;
reg [31:0] cells [255:0];

always @(posedge read_clk) begin
  if (mem_read) begin
    data_out <= cells[read_addr];
  end
end

always @(posedge write_clk) begin
  if (mem_write) begin
    cells[write_addr] <= data_in;
  end
end

endmodule