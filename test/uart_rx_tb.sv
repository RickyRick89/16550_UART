`timescale 1ns/1ps

module uart_rx_tb;

    // Parameters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    parameter CLK_FREQ = 100_000_000;
    parameter BAUD_RATE = 9600;
    parameter OVERSAMPLE = 16;
    parameter CLK_PERIOD = 1_000_000_000 / CLK_FREQ;
    parameter SAMPLE_TICK_PERIOD = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);

    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    logic clk = 0;
    logic rst = 1;
    logic rxd = 1;
    logic sample_tick;
    logic stop_bits = 0;
    logic parity_en = 0;
    logic parity_even = 1;
    logic enable = 1;

    logic enable_sample;
    logic data_ready;
    logic [7:0] data_out;
    logic parity_err;
    logic framing_err;
	
    int tick_div = 0;
	int timeout = 0;
	int max_timeout = 100_000;

    // Clock generation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always #(CLK_PERIOD / 2) clk = ~clk;
	
    // Gated tick generation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always_ff @(posedge clk) begin
        if (rst || ~enable_sample) begin
            tick_div <= 0;
            sample_tick <= 0;
        end else if (tick_div == SAMPLE_TICK_PERIOD - 1) begin
            tick_div <= 0;
            sample_tick <= 1;
        end else begin
            tick_div <= tick_div + 1;
            sample_tick <= 0;
        end
    end
	
    // Instantiate DUT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    uart_rx dut (
        .clk(clk),
        .rst(rst),
        .rxd(rxd),
        .sample_tick(sample_tick),
        .stop_bits(stop_bits),
        .parity_en(parity_en),
        .parity_even(parity_even),
		.data_bits(8), 
        .enable(enable),
        .enable_sample(enable_sample),
        .data_ready(data_ready),
        .data_out(data_out),
        .parity_err(parity_err),
        .framing_err(framing_err)
    );



    // Test Tasks ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	task automatic send_uart_byte(
		input [7:0] data,
		input bit include_parity,
		input bit force_parity_error,
		input bit stop_bit_value
	);
		int i, t;
		bit parity = ^data;
		if (!parity_even) parity = ~parity;

		// Start bit
		rxd = 0;
		repeat (16) @(posedge sample_tick);

		// Data bits
		for (i = 0; i < 8; i++) begin
			rxd = data[i];
			repeat (16) @(posedge sample_tick);
		end

		// Parity bit
		if (include_parity) begin
			rxd = force_parity_error ? ~parity : parity;
			repeat (16) @(posedge sample_tick);
		end

		// Stop bit
		rxd = stop_bit_value;
	endtask

    task wait_for_rx_and_check(
		input [7:0] expected,
		input bit expected_pe,
		input bit expected_fe
	);

		while ((data_ready !== 1) && timeout < max_timeout) begin
			@(posedge clk);
			timeout++;
		end

		if (timeout >= max_timeout) begin
			$display("ERROR: data_ready was never asserted!");
			$finish;
		end

		@(posedge clk);
		$display("Data = 0x%02x PE=%0b FE=%0b", data_out, parity_err, framing_err);

		if (data_out !== expected || parity_err !== expected_pe || framing_err !== expected_fe) begin
			$display("FAILED: Expected 0x%02x (PE=%0b, FE=%0b)", expected, expected_pe, expected_fe);
			$finish;
		end
	endtask


    // Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initial begin
        $display("Starting uart_rx testbench...");
        rxd = 1;
        rst = 1;
        repeat (4) @(posedge clk);
        rst = 0;

        $display("Test:Normal Frame");
        parity_en = 0;
        send_uart_byte(8'hA5, 0, 0, 1);
        wait_for_rx_and_check(8'hA5, 0, 0);

        $display("Test:Parity Error");
        parity_en = 1;
        parity_even = 1;
        send_uart_byte(8'h3C, 1, 1, 1);
        wait_for_rx_and_check(8'h3C, 1, 0);

        $display("Test:Framing Error");
        parity_en = 0;
        send_uart_byte(8'h5A, 0, 0, 0);
        wait_for_rx_and_check(8'h5A, 0, 1);

        $display("Test:Multi-byte");
        repeat (3) begin
            send_uart_byte(8'h55, 0, 0, 1);
            wait_for_rx_and_check( 8'h55, 0, 0);
        end

        $display("All tests complete! ");
        $finish;
    end

endmodule
