`timescale 1ns/1ps

module uart_loopback_tb;

    // Parameters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    parameter CLK_FREQ = 16_000_000;
    parameter BAUD_RATE = 9600;
    parameter OVERSAMPLE = 16;
    parameter CLK_PERIOD = 1_000_000_000 / CLK_FREQ;
    parameter BAUD_TICK_PERIOD = CLK_FREQ / BAUD_RATE;
    parameter SAMPLE_TICK_PERIOD = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);

    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    logic clk = 0;
    logic rst = 1;

    // UART signals
    logic txd, rxd;
    assign rxd = txd; // loopback wire

    // TX interface
    logic [7:0] tx_data;
    logic       tx_start;
    logic       tx_busy;
    logic [3:0] data_bits = 8;
    logic       enable_baud;
    logic       tick;

    // RX interface
    logic       enable_sample;
    logic       sample_tick;
    logic [7:0] rx_data;
    logic       data_ready;
    logic       parity_err;
    logic       framing_err;

    // config
    logic [1:0] stop_bits = 2'd1;
    logic       parity_en = 0;
    logic       parity_even = 1;
	
	
	logic [7:0] test_bytes[0:1];

    // Clock generation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Gated tick generation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Baud tick
    int tick_cnt = 0;
    always_ff @(posedge clk) begin
        if (rst || !enable_baud) begin
            tick_cnt <= 0;
            tick <= 0;
        end else if (tick_cnt == BAUD_TICK_PERIOD - 1) begin
            tick_cnt <= 0;
            tick <= 1;
        end else begin
            tick_cnt <= tick_cnt + 1;
            tick <= 0;
        end
    end

    // Sample tick
    int sample_cnt = 0;
    always_ff @(posedge clk) begin
        if (rst || !enable_sample) begin
            sample_cnt <= 0;
            sample_tick <= 0;
        end else if (sample_cnt == SAMPLE_TICK_PERIOD - 1) begin
            sample_cnt <= 0;
            sample_tick <= 1;
        end else begin
            sample_cnt <= sample_cnt + 1;
            sample_tick <= 0;
        end
    end

    // Instantiate DUTs ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    uart_tx tx (
        .clk(clk),
        .rst(rst),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .data_bits(data_bits),
        .parity_en(parity_en),
        .parity_even(parity_even),
        .stop_bits(stop_bits),
        .tick(tick),
        .txd(txd),
        .enable_baud(enable_baud)
    );

    uart_rx rx (
        .clk(clk),
        .rst(rst),
        .rxd(rxd),
        .sample_tick(sample_tick),
        .stop_bits(stop_bits),
        .parity_en(parity_en),
        .parity_even(parity_even),
        .data_bits(data_bits),
        .enable(1'b1),
        .enable_sample(enable_sample),
        .data_ready(data_ready),
        .data_out(rx_data),
        .parity_err(parity_err),
        .framing_err(framing_err)
    );

    // Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initial begin
        $display("Starting UART loopback testbench...");
        tx_data = 8'h00;
        tx_start = 0;

        rst = 1;
        repeat (10) @(posedge clk);
        rst = 0;

        test_bytes[0] = 8'hA5;
        test_bytes[1] = 8'h3C;

        foreach (test_bytes[i]) begin
            @(posedge clk);
            tx_data = test_bytes[i];
            tx_start = 1;
            @(posedge clk);
            tx_start = 0;

            wait (data_ready);
            @(posedge clk);

            $display("RX received: 0x%02x (P=%b F=%b)", rx_data, parity_err, framing_err);
            if (parity_err || framing_err || rx_data !== test_bytes[i]) begin
                $display("ERROR at index %0d: expected 0x%02x, got 0x%02x", i, test_bytes[i], rx_data);
				$finish;
			end
        end

        $display("UART LOOPBACK TEST PASSED");
        $finish;
    end

endmodule
