`timescale 1ns/1ps

module baud_gen_tb;

    parameter DL_WIDTH = 16;
    parameter PSD_WIDTH = 4;
	
	parameter CLK_PERIOD = 10;

    typedef logic [DL_WIDTH-1:0] DL_word_t;
    typedef logic [PSD_WIDTH-1:0] PSD_word_t;
	
    typedef struct packed {
        DL_word_t dl;
        PSD_word_t prc;
    } test_case_t;

    test_case_t tests[] = '{
		test_case_t'{dl: 16'd651, prc: 4'd0}, 	// 9600 bps
		test_case_t'{dl: 16'd325, prc: 4'd1}, 	// 9600 bps
		test_case_t'{dl: 16'd325, prc: 4'd0},	// 19200 bps
		test_case_t'{dl: 16'd108, prc: 4'd0},	// 57600 bps
		test_case_t'{dl: 16'd54,  prc: 4'd0}	// 15200 bps
	};



    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Tick counters
    logic [31:0] baud_clk_count = 0;
    logic [31:0] baud_clk_target = 0;
    logic [31:0] sample_clk_count = 0;
    logic [31:0] sample_clk_target = 0;
	
	// DUT
    logic clk;
    logic reset;
    DL_word_t divisor_latch;
    PSD_word_t psd;
    logic new_baud;
    logic baud_tick;
    logic sample_tick;
    logic active;
	logic enable_sample;
	logic enable_baud;

    // Instantiate DUT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	baud_gen #(
		.DL_WIDTH(DL_WIDTH),
		.PSD_WIDTH(PSD_WIDTH)
	) dut (
		.clk(clk),
		.reset(reset),
		.divisor_latch(divisor_latch),
		.psd(psd),
		.new_baud(new_baud),
		.enable_sample(enable_sample),
		.enable_baud(enable_baud),
		.baud_tick(baud_tick),
		.sample_tick(sample_tick),
		.active(active)
	);



    // Clock generation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always #(CLK_PERIOD/2) clk = ~clk;

	// Tick counters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always_ff @(posedge clk) begin
        if (active) begin
			baud_clk_count <= baud_clk_count + 1;
			sample_clk_count <= sample_clk_count + 1;
        end else begin
            baud_clk_count   <= 0;
            sample_clk_count <= 0;
        end
    end

    // Main test logic ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initial begin
        clk = 0;
        reset = 1;
        new_baud = 0;
        divisor_latch = 0;
        psd = 0;
        @(posedge clk);

        reset = 0;
        @(posedge clk);
		enable_sample = 1;
		enable_baud = 1;
		
        // Test default DL and PSD
		baud_clk_target = 1_048_576;
		sample_clk_target = 65_536;
		
		if (active === 1'bx || active === 1'bz) begin
			$display("Failed. Active signal is not valid!");
			$finish;
		end
        wait (active);
		
        wait (sample_tick);
        if (sample_clk_count !== sample_clk_target) begin
			$display("Failed sample tick test!");
			$display("Expected clock count: %0d. Actual clock count: %0d.",sample_clk_target, sample_clk_count);
			$stop;
        end

        wait (baud_tick);
        if (baud_clk_count !== baud_clk_target) begin
			$display("Failed baud tick test!");
			$display("Expected clock count: %0d. Actual clock count: %0d.",sample_clk_target, baud_clk_count);
			$stop;
        end

        // Increment through test vector
        foreach (tests[i]) begin
            divisor_latch = tests[i].dl;
            psd = tests[i].prc;
			new_baud = 1;
			@(posedge clk);
			new_baud = 0;
			
			baud_clk_target = divisor_latch * (psd + 1) * 16;
			sample_clk_target = divisor_latch * (psd + 1);
			
			
			wait (!active);
			wait (active);
			
			wait (sample_tick);
			if (sample_clk_count !== sample_clk_target) begin
				$display("Failed sample tick test!");
				$display("Expected clock count: %0d. Actual clock count: %0d.",sample_clk_target, sample_clk_count);
				$stop;
			end

			wait (baud_tick); // wait for sample tick
			if (baud_clk_count !== baud_clk_target) begin
				$display("Failed baud tick test!");
				$display("Expected clock count: %0d. Actual clock count: %0d.",sample_clk_target, baud_clk_count);
				$stop;
			end
		end

		$display("All tests completed!");
		$finish;
    end

endmodule
