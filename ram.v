module ram(
    input [31:0] addr,
    input [31:0] data_in,
    output reg [31:0] data_out = 0,
    input mem_read,
    input mem_en,
    input clk
);

integer i;
reg [31:0] cells [255:0];
initial for (i=0;i<256;i=i+1) cells[i] = 32'b0;

always @(posedge clk) begin
  if (mem_en && 256 <= addr && addr < 256 + 256) begin
    // $display("addr=%x, mem_read=%b, data_in=%x, data_out=%x", addr, mem_read, data_in, data_out);
    if (mem_read) begin
      data_out <= cells[addr[7:0]];
    end else begin
      cells[addr[7:0]] <= data_in;
    end
    // #1 $display(cells[16'he8]);
  end
end

endmodule