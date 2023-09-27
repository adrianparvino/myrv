(* top *)
module top(
    input clk,
    output reg [5:0] led = ~6'b0,
    output uart_tx,
    input uart_rx,

    input key
);

wire [31:0] pc;
wire [31:0] instruction;

wire [31:0] data_in = ram_select ? ram_out : uart_rx_select ? {24'b0, uart_rx_data} : 0;
wire [31:0] data_out;
wire [31:0] addr;

wire [31:0] ram_out;

wire mem_read;
wire mem_en;
wire read_ack = ram_select ? ram_read_ack : uart_rx_select ? uart_rx_ack : 0;
wire ram_read_ack;

wire tx_available;
wire [7:0] tx_data;
wire tx_ack;

wire rx_available;
wire [7:0] uart_rx_data;
wire uart_rx_ack;

wire ram_select = 256 <= addr && addr < 256 + 256;
wire led_select = addr == 1024;
wire uart_tx_select = addr == 1028;
wire uart_rx_select = addr == 1032;

wire sysclk = pll_out & lock;
wire pll_out;
wire lock;
rPLL #( // For GW1NR-9 C6/I5
  .FCLKIN("27"),
  .IDIV_SEL(8), // -> PFD = 3 MHz (range: 3-400 MHz)
  .FBDIV_SEL(3), // -> CLKOUT = 12 MHz (range: 3.125-500 MHz)
  .ODIV_SEL(48) // -> VCO = 576 MHz (range: 400-1000 MHz)
) pll (.CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), .RESET(1'b0), .RESET_P(1'b0), .CLKFB(1'b0), .FBDSEL(6'b0), .IDSEL(6'b0), .ODSEL(6'b0), .PSDA(4'b0), .DUTYDA(4'b0), .FDLY(4'b0),
  .CLKIN(clk), // 27 MHz
  .CLKOUT(pll_out), // 12 MHz
  .LOCK(lock)
);

uart uart(
    .clk(sysclk),
    .uart_tx(uart_tx),
    .uart_rx(uart_rx),

    .tx_available(mem_en && !mem_read && uart_tx_select),
    .tx_data(data_out[7:0]),
    .tx_ack(tx_ack),

    .rx_available(rx_available),
    .rx_data(uart_rx_data),
    .rx_pop(mem_en && mem_read && uart_rx_select),
    .rx_ack(uart_rx_ack)
);

ram ram(
    .read_addr(addr[7:2]),
    .data_out(ram_out),
    .mem_read(mem_en && mem_read && ram_select),
    .read_ack(ram_read_ack),
    .read_clk(sysclk),

    .write_addr(addr[7:2]),
    .data_in(data_out),
    .mem_write(mem_en && !mem_read && ram_select),
    .write_clk(sysclk)
);

rom rom(
    .pc(pc), 
    .instruction(instruction)
);

furv furv(
    .instruction(instruction),
    .pc(pc),

    .data_in(data_in),
    .data_out(data_out),
    .addr(addr),
    .mem_read(mem_read),
    .mem_en(mem_en),
    .read_ack(read_ack),
    .clk(sysclk)
);

always @(*) begin
    led[0] <= ~lock;
end

always @(posedge sysclk) begin
    if (mem_en && !mem_read && led_select) begin
        led[5:1] <= ~data_out[4:0];
    end
end

endmodule
