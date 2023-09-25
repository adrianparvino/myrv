module uart(
    input clk,
    output reg uart_tx = 1,
    input uart_rx,
);

reg [7:0] tx_shift_register = "a";
reg tx_data_ready = 0;
reg [7:0] tx_divider = 1;
reg [3:0] tx_state = 8;
wire [7:0] tx_next = tx_divider + 1;
always @(negedge clk) begin
  if (tx_state == 9) begin
    if (tx_data_ready != rx_data_ready) begin
      tx_divider <= 0;
      tx_state <= 15;
      tx_data_ready <= ~tx_data_ready;
      tx_shift_register <= rx_shift_register;
    end
  end else begin
    if (tx_divider == 0) begin
      if (tx_state < 8) begin
        uart_tx <= tx_shift_register[0];

        tx_shift_register <= {1'b0, tx_shift_register[7:1]};
      end else begin
        uart_tx <= ~tx_state[0];
      end

      tx_state <= tx_state + 1;
    end
  end

  tx_divider <= (tx_next == 234) ? 0 : tx_next;
end

reg [7:0] rx_shift_register = 8'b01010101;
reg [3:0] rx_state = 9;
reg [7:0] rx_divider = 0;
reg rx_data_ready = 0;
wire [7:0] rx_next = rx_divider + 1;
always @(negedge clk) begin
  if (rx_state == 9) begin
    if (uart_rx == 0) begin
      rx_divider <= 117;
      rx_state <= 15;
    end
  end else begin
    if (rx_divider == 0) begin
      if (rx_state < 8) begin
        rx_shift_register <= {uart_rx, rx_shift_register[7:1]};
      end else if (rx_state == 8) begin
        rx_data_ready <= ~rx_data_ready;
      end

      rx_state <= rx_state + 1;
    end

    rx_divider <= (rx_next == 234) ? 0 : rx_next;
  end
end

endmodule
