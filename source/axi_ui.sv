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

    import uart_16550_regs_pkg::*;
    import axi4_lite_pkg::*;

    uart_16550_regs_t regs;

    logic [2:0] axi_rd_addr;
    logic [7:0] axi_wr_data;
    logic axi_wr_en, axi_rd_en;
    logic [2:0] wr_addr_latched;
    logic wr_handshake;
    logic rhr_has_data;

    assign regs_out = regs;
    assign irq = (regs.isr.int_id != 4'b0001);
    assign irq_n = ~irq;
    assign wr_handshake = awvalid && wvalid && awready && wready;

    assign rd_en = (rx_ready && !rhr_has_data);

    // AXI Write FSM
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            awready <= 0;
            wready  <= 0;
            bvalid  <= 0;
            bresp   <= AXI_RESP_OKAY;
            axi_wr_en <= 0;
            wr_en <= 0;
            new_baud <= 0;
            regs = uart_16550_default();
        end else begin
            awready <= !awready && awvalid;
            wready  <= !wready  && wvalid;

            if (wr_handshake) begin
                wr_addr_latched <= awaddr[2:0];
                axi_wr_data     <= wdata[7:0];
                axi_wr_en       <= 1;
            end else begin
                axi_wr_en <= 0;
            end

            wr_en <= 0;
            new_baud <= 0;
            if (axi_wr_en) begin
                regs <= uart_reg_write(regs, wr_addr_latched, axi_wr_data);
                if (wr_addr_latched == 3'd0 && !regs.lcr.dlab)
                    wr_en <= 1;

                if (regs.lcr.dlab && (wr_addr_latched == 3'd0 || wr_addr_latched == 3'd1 || wr_addr_latched == 3'd5))
                    new_baud <= 1;
            end

            if (axi_wr_en) begin
                bvalid <= 1;
                bresp  <= AXI_RESP_OKAY;
            end else if (bvalid && bready) begin
                bvalid <= 0;
            end
        end
    end

    // AXI Read FSM
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            arready <= 0;
            rvalid  <= 0;
            rdata   <= 0;
            rresp   <= AXI_RESP_OKAY;
            axi_rd_en <= 0;
        end else begin
            arready <= arvalid && !arready;

            if (arvalid && !arready) begin
                axi_rd_addr <= araddr[2:0];
                axi_rd_en   <= 1;
            end else begin
                axi_rd_en <= 0;
            end

            if (axi_rd_en) begin
                rvalid <= 1;
                rresp  <= AXI_RESP_OKAY;

                if ((axi_rd_addr == 3'd0) && !regs.lcr.dlab) begin
                    rdata <= {24'd0, rd_data};
                    rhr_has_data <= 0; // Clear valid flag after read
                end else begin
                    rdata <= {24'd0, uart_reg_read(regs, axi_rd_addr)};
                end
            end else if (rvalid && rready) begin
                rvalid <= 0;
            end
        end
    end

    // FIFO read request trigger
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_en <= 0;
        end else begin
            rd_en <= (rx_ready && !rhr_has_data);
        end
    end

    // FIFO read data capture
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rhr_has_data <= 0;
        end else if (rx_valid) begin
            rhr_has_data <= 1;
        end
    end

    // LSR flags update
    always_ff @(posedge clk) begin
        regs.lsr.data_ready  <= rhr_has_data;
        regs.lsr.overrun_err <= overrun_err;
        regs.lsr.parity_err  <= parity_err;
        regs.lsr.framing_err <= framing_err;
        regs.lsr.thr_empty   <= tx_ready;
        regs.lsr.tx_empty    <= tx_ready;
    end

    // ISR update logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            regs.isr.int_id     <= 4'b0001;
            regs.isr.int_status <= 1'b1;
        end else begin
            if (regs.ier.rx_line_status_int_en && (parity_err || framing_err || overrun_err)) begin
                regs.isr.int_id     <= 4'b0110;
                regs.isr.int_status <= 1'b0;
            end else if (regs.ier.data_ready_int_en && rhr_has_data) begin
                regs.isr.int_id     <= 4'b0100;
                regs.isr.int_status <= 1'b0;
            end else if (regs.ier.thr_empty_int_en && tx_ready) begin
                regs.isr.int_id     <= 4'b0010;
                regs.isr.int_status <= 1'b0;
            end else begin
                regs.isr.int_id     <= 4'b0001;
                regs.isr.int_status <= 1'b1;
            end
        end
    end

endmodule
