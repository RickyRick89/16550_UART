`timescale 1ns/1ps

module shift_mult_tb;


	parameter MULTIPLICAND_WIDTH = 16;
	parameter MULTIPLIER_WIDTH = 8;
	parameter PRODUCT_WIDTH = MULTIPLICAND_WIDTH + MULTIPLIER_WIDTH;
	typedef logic [MULTIPLICAND_WIDTH-1:0] multiplicand_word_t;
	typedef logic [MULTIPLIER_WIDTH-1:0] multiplier_word_t;
	typedef logic [PRODUCT_WIDTH-1:0] product_word_t;


	logic clk, rst_n, start;
	multiplicand_word_t multiplicand;
	multiplier_word_t multiplier;
	product_word_t product;
	logic busy;
	product_word_t expected_val;
	int NUM_TESTS = 10_000;
	int i;
	int watchdog;

  // Instantiation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	shift_mult #(
		.MULTIPLICAND_WIDTH(MULTIPLICAND_WIDTH),
		.MULTIPLIER_WIDTH(MULTIPLIER_WIDTH)
	) uut (
		.multiplicand(multiplicand),
		.multiplier(multiplier),
		.start(start),
		.clk(clk),
		.rst_n(rst_n),
		.product(product),
		.busy(busy)
	);

	// Clock gen ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	always #5 clk = ~clk;

	initial begin
		// Initialize
		clk = 0;
		rst_n = 0;
		start = 0;
		multiplicand = 0;
		multiplier = 0;
		@(posedge clk);

		// Release reset
		rst_n = 1;
		@(posedge clk);

		for (i = 0; i < NUM_TESTS; i++) begin
			// Generate random operands
			multiplicand = $urandom();
			multiplier   = $urandom();
			expected_val = multiplicand * multiplier;

			// Apply start
			start = 1;
			@(posedge clk);
			start = 0;
			@(posedge clk);

			// Wait for mult to complete
			watchdog = 0;
			while (busy !== 0) begin
				@(posedge clk);
				watchdog += 1;
				if (watchdog > MULTIPLIER_WIDTH) begin
					$display("Watchdog timed out!");
					$finish;
				end
			end
			
			if (product !== expected_val) begin
				$display("Failed Multiplication!");
				$display("%0d * %0d = %0d (got: %0d)",multiplicand, multiplier, expected_val, product);
				$stop;
			end
		end

		$display("All tests completed!");
		$finish;
	end

endmodule
