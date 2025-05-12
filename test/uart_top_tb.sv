`timescale 1ns/1ps

module uart_top_tb;

    // Parameters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    parameter CLK_FREQ = 100_000_000;
    parameter BAUD_RATE = 9600;
    parameter CLK_PERIOD = 1_000_000_000 / CLK_FREQ;
    parameter DL_WIDTH = 16;
    parameter PSD_WIDTH = 4;

    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    logic clk = 0;
    logic rst = 1;

    // UART serial wires
    logic txd, rxd;
    assign rxd = txd; // loopback

    // TX write
    logic        wr_en;
    logic [7:0]  wr_data;
    logic        tx_ready;

    // RX read
    logic        rd_en;
    logic [7:0]  rd_data;
    logic        rx_ready;

    // Errors
    logic parity_err, framing_err, overrun_err;

    // Config
    logic [1:0]  stop_bits     = 2'd1;
    logic        parity_en     = 0;
    logic        parity_even   = 1;
    logic [3:0]  data_bits     = 4'd8;
    logic [DL_WIDTH-1:0] divisor_latch = 16'd651;
    logic [PSD_WIDTH-1:0] psd = 4'd0;
    logic new_baud = 0;

    logic [7:0] tx_data[0:1];
    int tx_ptr = 0;
    int rx_count = 0;

    // Clock generation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Instantiate DUT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    uart_top #(
        .DL_WIDTH(DL_WIDTH),
        .PSD_WIDTH(PSD_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rxd(rxd),
        .txd(txd),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .tx_ready(tx_ready),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .rx_ready(rx_ready),
        .parity_err(parity_err),
        .framing_err(framing_err),
        .overrun_err(overrun_err),
        .stop_bits(stop_bits),
        .parity_en(parity_en),
        .parity_even(parity_even),
        .data_bits(data_bits),
        .divisor_latch(divisor_latch),
        .psd(psd),
        .new_baud(new_baud)
    );
	
    // Test Tasks ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	task automatic wait_with_timeout(ref logic condition, input string label, input int max_cycles = 100_000);
		int cycles = 0;
		while ((condition !== 1) && (cycles < max_cycles)) begin
			@(posedge clk);
			cycles++;
		end
		if (cycles >= max_cycles) begin
			$display("TIMEOUT: '%s' did not assert after %0d cycles", label, max_cycles);
			$finish;
		end
	endtask


    // Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initial begin
        $display("Starting uart_top loopback test...");
        tx_data[0] = 8'hA5;
        tx_data[1] = 8'h3C;

        wr_en = 0;
        rd_en = 0;
        rst   = 1;

        repeat (10) @(posedge clk);
        rst = 0;

        // Setup baud
        new_baud = 1;
        @(posedge clk);
        new_baud = 0;

        // Write TX data
        foreach (tx_data[i]) begin
			wait_with_timeout(tx_ready, "tx_ready");
            wr_data = tx_data[i];
            wr_en = 1;
            @(posedge clk);
            wr_en = 0;
        end

        // Read back RX
		while (rx_count < 2) begin
			wait_with_timeout(rx_ready, "rx_ready", 100_000_000);
			rd_en = 1;
			@(posedge clk);
			rd_en = 0;

			$display("RX[%0d] = 0x%02x", rx_count, rd_data);
			rx_count++;
		end


        $display("All UART Top loopback tests complete!");
        $finish;
    end

endmodule
