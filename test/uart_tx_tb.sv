`timescale 1ns/1ps

module uart_tx_tb;

    // Parameters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    parameter CLK_PERIOD = 10;
    parameter BAUD_PERIOD = 8680; // ~115200 bps
	
	
    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    logic clk = 0, rst = 1;

    // DUT interface
    logic [7:0]  tx_data;
    logic        tx_start;
    logic        tx_busy;
    logic [3:0]  data_bits;
    logic        parity_en;
    logic        parity_even;
    logic [1:0]  stop_bits;
    logic        tick;
    logic        txd;
    logic        enable_baud;

    // Clock generation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always #(CLK_PERIOD/2) clk = ~clk;

    // Gated tick generation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initial begin
        tick = 0;
        forever begin
            #(BAUD_PERIOD);
            if (enable_baud) begin
                tick = 1;
                #(CLK_PERIOD);
                tick = 0;
            end
        end
    end

    // Instantiate DUT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    uart_tx dut (
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

    // Test Tasks ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    task automatic send_uart_frame(
		input [7:0] data,
		input [3:0] bits,
		input       parity,
		input       even,
		input [1:0] stops
	);
		int timeout;
		int timeout_busy_start = 100_000;
		int timeout_busy_stop = 1_000_000;

		$display("Sending: data=0x%02x, bits=%0d, parity=%0b, even=%0b, stop_bits=%0d", data, bits, parity, even, stops);

		tx_data     = data;
		data_bits   = bits;
		parity_en   = parity;
		parity_even = even;
		stop_bits   = stops;

		@(posedge clk);
		tx_start = 1;
		@(posedge clk);
		tx_start = 0;

		// Wait for tx_busy to go high
		timeout = 0;
		while ((tx_busy !== 1) && timeout < timeout_busy_start) begin
			@(posedge clk);
			timeout++;
		end
		if (timeout >= timeout_busy_start) begin
			$display("ERROR: TX never started (tx_busy never went high)");
			$finish;
		end

		// Wait for tx_busy to go low
		timeout = 0;
		while ((tx_busy === 1) && timeout < timeout_busy_stop) begin
			@(posedge clk);
			timeout++;
		end
		if (timeout >= timeout_busy_stop) begin
			$display("ERROR: TX never completed (tx_busy stuck high)");
			$finish;
		end

		repeat (2) @(posedge clk);
	endtask


    // Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initial begin
        tx_start     = 0;
        tx_data      = 8'h00;
        parity_en    = 0;
        parity_even  = 1;
        stop_bits    = 2'd1;
        data_bits    = 8;

        #100 rst = 0;

        // No parity, 1 stop
        send_uart_frame(8'hA5, 8, 0, 1, 1);

        // Parity even
        send_uart_frame(8'h3C, 8, 1, 1, 1);

        // Parity odd
        send_uart_frame(8'h55, 8, 1, 0, 1);

        // 7 bits, even parity, 2 stop bits
        send_uart_frame(8'h6B, 7, 1, 1, 2);

        // 6-bit data, no parity, 1 stop bit
        send_uart_frame(8'h0F, 6, 0, 0, 1);

        // 5-bit data, odd parity, 2 stop bits
        send_uart_frame(8'h1B, 5, 1, 0, 2);

        $display("All TX tests complete.");
        $finish;
    end

endmodule
