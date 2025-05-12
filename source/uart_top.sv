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

    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Baud Control
    logic baud_tick, sample_tick;
    logic enable_baud, enable_sample;

    // TX
    logic [7:0] tx_data;
    logic       tx_start, tx_busy;
    logic       tx_fifo_empty, tx_fifo_full;
    logic       tx_rd_valid;
    logic [7:0] tx_fifo_rd_data;

    // RX
    logic [7:0] rx_data_out;
    logic       rx_data_ready;
    logic       rx_parity_err, rx_framing_err;
    logic       rx_fifo_full, rx_fifo_empty;
    logic       rx_rd_valid;
    logic 		rx_fifo_wr_en; 
    logic [7:0] rx_fifo_rd_data;

    // Assignments ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    assign tx_ready = ~tx_fifo_full;
    assign rx_ready = ~rx_fifo_empty;
    assign rd_data  = rx_fifo_rd_data;
    assign tx_data  = tx_fifo_rd_data;
    assign rx_fifo_wr_en = rx_data_ready && ~rx_fifo_full;

    // Instantiations ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // TX FIFO
    fifo_lite #(.WIDTH(8), .DEPTH(FIFO_DEPTH)) tx_fifo (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(tx_start),
        .rd_data(tx_fifo_rd_data),
        .rd_valid(tx_rd_valid),
        .full(tx_fifo_full),
        .empty(tx_fifo_empty)
    );

    // RX FIFO
    fifo_lite #(.WIDTH(8), .DEPTH(FIFO_DEPTH)) rx_fifo (
        .clk(clk),
        .rst(rst),
        .wr_en(rx_fifo_wr_en),
        .wr_data(rx_data_out),
        .rd_en(rd_en),
        .rd_data(rx_fifo_rd_data),
        .rd_valid(rx_rd_valid),
        .full(rx_fifo_full),
        .empty(rx_fifo_empty)
    );

    // Baud Generator
    baud_gen #(
        .DL_WIDTH(DL_WIDTH),
        .PSD_WIDTH(PSD_WIDTH)
    ) baud_gen_inst (
        .clk(clk),
        .reset(rst),
        .divisor_latch(divisor_latch),
        .psd(psd),
        .new_baud(new_baud),
        .enable_sample(enable_sample),
        .enable_baud(enable_baud),
        .baud_tick(baud_tick),
        .sample_tick(sample_tick),
        .active()
    );

    // TX Core
    uart_tx tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .data_bits(data_bits),
        .parity_en(parity_en),
        .parity_even(parity_even),
        .stop_bits(stop_bits),
        .tick(baud_tick),
        .txd(txd),
        .enable_baud(enable_baud)
    );

    // RX Core
    uart_rx rx_inst (
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
        .data_ready(rx_data_ready),
        .data_out(rx_data_out),
        .parity_err(rx_parity_err),
        .framing_err(rx_framing_err)
    );

    // Control Logic ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // TX Start Control
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_start <= 0;
        end else begin
            if (~tx_busy && ~tx_fifo_empty && !tx_start)
                tx_start <= 1;
            else
                tx_start <= 0;
        end
    end
	
    // Error Flags
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            parity_err   <= 0;
            framing_err  <= 0;
            overrun_err  <= 0;
        end else begin
            parity_err   <= rx_data_ready && rx_parity_err;
            framing_err  <= rx_data_ready && rx_framing_err;
            overrun_err  <= rx_data_ready && rx_fifo_full;
        end
    end

endmodule
