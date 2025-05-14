`timescale 1ns/1ps
`include "axi4_lite_pkg.sv"
`include "uart_16550_regs_pkg.sv"

module uart_16550 #(
    parameter DL_WIDTH = 16,
    parameter PSD_WIDTH = 4,
    parameter FIFO_DEPTH = 16
)(
    input  logic clk,
    input  logic rst,

    // AXI4-Lite Interface
    input  axi4_lite_pkg::axi_lite_addr_t awaddr,
    input  logic                          awvalid,
    output logic                          awready,

    input  axi4_lite_pkg::axi_lite_data_t wdata,
    input  axi4_lite_pkg::axi_lite_strb_t wstrb,
    input  logic                          wvalid,
    output logic                          wready,

    output logic                          bvalid,
    output axi4_lite_pkg::axi_lite_resp_t bresp,
    input  logic                          bready,

    input  axi4_lite_pkg::axi_lite_addr_t araddr,
    input  logic                          arvalid,
    output logic                          arready,

    output axi4_lite_pkg::axi_lite_data_t rdata,
    output logic                          rvalid,
    output axi4_lite_pkg::axi_lite_resp_t rresp,
    input  logic                          rready,

    // IRQ outputs
    output logic irq,
    output logic irq_n,

    // UART Serial I/O
    input  logic rxd,
    output logic txd
);
	// Imports ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    import uart_16550_regs_pkg::*;

    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    uart_16550_regs_t regs;
    logic wr_en, rd_en;
    logic [7:0] rd_data;
    logic tx_ready, rx_ready, rx_valid;
    logic parity_err, framing_err, overrun_err;
	logic new_baud;
	logic [3:0] data_bits;
	
    // Assignments ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	assign data_bits = 4'd5 + regs.lcr.word_length;

    // Instantiations ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // UART Top
    uart_top #(
        .DL_WIDTH(DL_WIDTH),
        .PSD_WIDTH(PSD_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) uart_core (
        .clk(clk),
        .rst(rst),
        .rxd(rxd),
        .txd(txd),
        .wr_en(wr_en),
        .wr_data(regs.thr),
        .tx_ready(tx_ready),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .rx_ready(rx_ready),
		.rx_valid(rx_valid),
        .parity_err(parity_err),
        .framing_err(framing_err),
        .overrun_err(overrun_err),
        .stop_bits(regs.lcr.stop_bits),
        .parity_en(regs.lcr.parity_en),
        .parity_even(regs.lcr.even_parity),
        .data_bits(data_bits),
        .divisor_latch({regs.dlm, regs.dll}),
        .psd(regs.psd[3:0]),
        .new_baud(new_baud)
    );

    // AXI UI
    axi_ui #(
        .DL_WIDTH(DL_WIDTH),
        .PSD_WIDTH(PSD_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) ui (
        .clk(clk),
        .rst(rst),
        .awaddr(awaddr),
        .awvalid(awvalid),
        .awready(awready),
        .wdata(wdata),
        .wvalid(wvalid),
        .wstrb(wstrb),
        .wready(wready),
        .bvalid(bvalid),
        .bresp(bresp),
        .bready(bready),
        .araddr(araddr),
        .arvalid(arvalid),
        .arready(arready),
        .rdata(rdata),
        .rvalid(rvalid),
        .rresp(rresp),
        .rready(rready),
        .regs_out(regs),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .tx_ready(tx_ready),
        .rx_ready(rx_ready),
		.rx_valid(rx_valid),
        .parity_err(parity_err),
        .framing_err(framing_err),
        .overrun_err(overrun_err),
		.new_baud(new_baud),
        .irq(irq),
        .irq_n(irq_n)
    );

endmodule
