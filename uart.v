module uart(
    input clk,
    output reg uart_tx = 1,
    input uart_rx,

    input tx_available,
    input [7:0] tx_data,
    output tx_ack,

    output reg rx_available = 0,
    output reg [7:0] rx_data = 0,
    input rx_pop,
    output reg rx_ack = 0
);

assign smth = uart_tx;

reg [7:0] tx_shift_register;
reg [7:0] tx_divider;
reg [3:0] tx_state = 14;
wire [7:0] tx_next = tx_divider + 1;
always @(posedge clk) begin
  if (tx_state == 14) begin
    if (tx_available) begin
      tx_divider <= 0;
      tx_state <= 15;
      tx_shift_register <= tx_data;
    end
  end else begin
    if (tx_divider == 0) begin
      if (tx_state == 15) begin
        uart_tx <= 0;
      end else begin
        uart_tx <= tx_shift_register[0];

        tx_shift_register <= {1'b1, tx_shift_register[7:1]};
      end

      tx_state <= tx_state + 1;
    end

    tx_divider <= (tx_next == 104) ? 0 : tx_next;
  end
end

reg [3:0] rx_state = 9;
reg [7:0] rx_divider;
wire [7:0] rx_next = rx_divider + 1;
always @(posedge clk) begin
  if (rx_pop && rx_available) begin
    rx_ack <= 1;
    rx_available <= 0;
  end else begin
    rx_ack <= 0;

    if (rx_state == 9) begin
      if (uart_rx == 0) begin
        rx_divider <= 57;
        rx_state <= 15;
      end
    end else begin
      if (rx_divider == 0) begin
        if (rx_state < 8) begin
          rx_data <= {uart_rx, rx_data[7:1]};
        end else if (rx_state == 8) begin
          rx_available <= 1;
        end

        rx_state <= rx_state + 1;
      end

      rx_divider <= (rx_next == 104) ? 0 : rx_next;
    end
  end
end

endmodule
