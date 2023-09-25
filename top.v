(* top *)
module top(
    input clk,
    output reg [5:0] led,
    output uart_tx,
    input uart_rx,
);


wire [31:0] pc;
wire [31:0] instruction;

wire [31:0] data_in;
wire [31:0] data_out;
wire [31:0] addr;

wire mem_read;
wire mem_en;

wire sysclk = counter[7];
// rPLL #( // For GW1NR-9 C6/I5
//   .FCLKIN("27"),
//   .IDIV_SEL(8), // -> PFD = 3 MHz (range: 3-400 MHz)
//   .FBDIV_SEL(3), // -> CLKOUT = 12 MHz (range: 3.125-500 MHz)
//   .ODIV_SEL(48) // -> VCO = 576 MHz (range: 400-1000 MHz)
// ) pll (.CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), .RESET(1'b0), .RESET_P(1'b0), .CLKFB(1'b0), .FBDSEL(6'b0), .IDSEL(6'b0), .ODSEL(6'b0), .PSDA(4'b0), .DUTYDA(4'b0), .FDLY(4'b0),
//   .CLKIN(clk), // 27 MHz
//   .CLKOUT(sysclk), // 12 MHz
//   .LOCK()
// );

reg [21:0] counter = 0;

initial begin
    led[5:0] = ~6'b0;
end

uart uart(
    .clk(clk),
    .uart_tx(uart_tx),
    .uart_rx(uart_rx),
);

ram ram(
    .addr(addr),
    .data_in(data_out),
    .data_out(data_in),
    .mem_read(mem_read),
    .mem_en(mem_en),
    .clk(sysclk)
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
    .clk(sysclk)
);

always @(posedge clk) begin
    counter <= counter + 1;
end

always @(posedge sysclk) begin
    if (mem_en && !mem_read && addr == 1024) begin
        led[5:0] <= ~data_out[5:0];
    end
end

endmodule
