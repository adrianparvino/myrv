module ram(
    input [5:0] read_addr,
    input [5:0] write_addr,
    input [31:0] data_in,
    output reg [31:0] data_out = 0,
    input mem_read,
    input mem_write,
    input read_clk,
    input write_clk,

    output reg read_ack = 0
);

integer i;
reg [31:0] cells [63:0];
initial for (i=0;i<64;i=i+1) cells[i] = 32'b0;

always @(posedge read_clk) begin
  if (mem_read) begin
    data_out <= cells[read_addr];
  end

  read_ack <= mem_read;
  // read_ack <= 0;
end

always @(posedge write_clk) begin
  if (mem_write) begin
    cells[write_addr] <= data_in;
  end
end

endmodule