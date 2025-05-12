module baud_gen #(
	parameter DL_WIDTH = 16,
	parameter PSD_WIDTH = 4,
	localparam type DL_word_t = logic [DL_WIDTH-1:0],
	localparam type PSD_word_t = logic [PSD_WIDTH-1:0]
) (
	input  logic        clk,
	input  logic        reset,             // Active-high reset
	input  DL_word_t    divisor_latch,     // DLM:DLL combined
	input  PSD_word_t   psd,               // Prescaler division (0–15) = divide by (PSD+1)
	input  logic        new_baud,          // Signal that a new baud rate should be calculated
	input  logic        enable_sample,     // Gate sample_tick generation
	input  logic        enable_baud,       // Gate baud_tick generation

	output logic        baud_tick,         // Pulse at baud rate
	output logic        sample_tick,       // Pulse at 16× baud rate
	output logic        active             // Signal that the baud generator is active
);

	localparam SAMPLE_WIDTH  = DL_WIDTH + PSD_WIDTH + 1;
	localparam DIVISOR_WIDTH = SAMPLE_WIDTH + 4;

	logic [DIVISOR_WIDTH-1:0] baud_divisor;       // 16*(psd+1)*div_latch
	logic [SAMPLE_WIDTH-1:0]  sample_divisor;     // (psd+1)*div_latch

	logic [DL_WIDTH:0]        dl_wrk;
	logic [PSD_WIDTH:0]       psd_wrk;

	logic start_mult;
	logic mult_busy;
	logic [SAMPLE_WIDTH-1:0] mult_product;

	logic mult_done;

	enum logic [2:0] { IDLE, MULT, PROC, DONE } state, next_state;

	// Adjusted divisor input values
	assign dl_wrk  = (divisor_latch == 'd0) ? 'd65536 : divisor_latch;
	assign psd_wrk = psd + 1;

	// Multiplier instantiation
	shift_mult #(
		.MULTIPLICAND_WIDTH(DL_WIDTH + 1),
		.MULTIPLIER_WIDTH(PSD_WIDTH + 1)
	) mult1 (
		.multiplicand(dl_wrk),
		.multiplier(psd_wrk),
		.start(start_mult),
		.clk(clk),
		.rst_n(!reset),
		.product(mult_product),
		.busy(mult_busy)
	);

	always_ff @(posedge clk)
		state <= next_state;


	always_comb begin
		next_state = state;
		start_mult = 0;

		case (state)
			IDLE:
				if (!mult_done) begin
					next_state = MULT;
					start_mult = 1;
				end

			MULT:
				if (!mult_busy)
					next_state = PROC;

			PROC:
				next_state = DONE;

			DONE:
				next_state = IDLE;
		endcase
		
		if (reset) next_state = IDLE;
	end

	always_comb begin
		if (reset)
			mult_done <= 0;
		else if (new_baud)
			mult_done <= 0;
		else if (state == PROC) begin
			sample_divisor 	<= mult_product - 1;
			baud_divisor   	<= (mult_product << 4) - 1;
		end
		else if (state == DONE) begin
			mult_done <= 1;
		end
		else 
			mult_done <= mult_done;
	end


	assign active = (mult_done);

	// Tick counters
	logic [SAMPLE_WIDTH-1:0]  sample_counter;
	logic [DIVISOR_WIDTH-1:0] baud_counter;

	always_ff @(posedge clk or posedge reset) begin
		if (reset || ~active) begin
			sample_counter <= sample_divisor;
			baud_counter   <= baud_divisor;
			sample_tick    <= 0;
			baud_tick      <= 0;
		end else begin
			// Sample tick
			if (enable_sample) begin
				if (sample_counter == 0) begin
					sample_tick    <= 1;
					sample_counter <= sample_divisor;
				end else begin
					sample_tick    <= 0;
					sample_counter <= sample_counter - 1;
				end
			end
			else begin
				sample_counter <= sample_divisor;
			end

			// Baud tick
			if (enable_baud) begin
				if (baud_counter == 0) begin
					baud_tick    <= 1;
					baud_counter <= baud_divisor;
				end else begin
					baud_tick    <= 0;
					baud_counter <= baud_counter - 1;
				end
			end
			else begin
				baud_counter <= baud_divisor;
			end
		end
	end

endmodule
