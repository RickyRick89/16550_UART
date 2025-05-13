`timescale 1ns/1ps
`include "../source/axi4_lite_pkg.sv"
`include "../source/uart_16550_regs_pkg.sv"

module axi_ui #(
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

    // UART Interface
    output uart_16550_regs_pkg::uart_16550_regs_t 	regs_out,
    output logic                            		wr_en,
    output logic                            		rd_en,
    input  logic [7:0]                      		rd_data,
    input  logic                            		tx_ready,
    input  logic                            		rx_ready,
    input  logic                            		rx_valid,
    input  logic                            		parity_err,
    input  logic                            		framing_err,
    input  logic                            		overrun_err,
    output logic 									new_baud,

    output logic irq,
    output logic irq_n
);
endmodule
