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
	output logic        baud_tick,         // Pulse at baud rate
	output logic        sample_tick,       // Pulse at 16× baud rate
	output logic        active             // Signal that the baud generator is active
);
endmodule
