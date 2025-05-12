module uart_top #(
    parameter DL_WIDTH = 16,
    parameter PSD_WIDTH = 4,
    parameter FIFO_DEPTH = 16
)(
    input  logic clk,
    input  logic rst,

    // Serial I/O
    input  logic rxd,
    output logic txd,

    // Write to TX FIFO
    input  logic        wr_en,
    input  logic [7:0]  wr_data,
    output logic        tx_ready,

    // Read from RX FIFO
    input  logic        rd_en,
    output logic [7:0]  rd_data,
    output logic        rx_ready,

    // Error flags (pulsed)
    output logic        parity_err,
    output logic        framing_err,
    output logic        overrun_err,

    // Line control
    input  logic [1:0]  stop_bits,
    input  logic        parity_en,
    input  logic        parity_even,
    input  logic [3:0]  data_bits,

    // Baud config
    input  logic [DL_WIDTH-1:0]  divisor_latch,
    input  logic [PSD_WIDTH-1:0] psd,
    input  logic                 new_baud
);
endmodule
