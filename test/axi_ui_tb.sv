`timescale 1ns/1ps
`include "../source/axi4_lite_pkg.sv"
`include "../source/uart_16550_regs_pkg.sv"

module axi_ui_tb;

    // Imports ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    import axi4_lite_pkg::*;
    import uart_16550_regs_pkg::*;

    // Parameters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    parameter DL_WIDTH = 16;
    parameter PSD_WIDTH = 4;
    parameter FIFO_DEPTH = 16;
    parameter CLK_PERIOD = 10;

    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    logic clk = 0;
    logic rst;

    axi_lite_addr_t awaddr, araddr;
    axi_lite_data_t wdata, rdata;
    axi_lite_strb_t wstrb = 4'b1111;
    axi_lite_resp_t bresp, rresp;

    logic awvalid, wvalid, bvalid, bready;
    logic arvalid, arready, rvalid, rready;
    logic awready, wready;

    uart_16550_regs_t regs_out;
    logic wr_en, rd_en;
    logic [7:0] rd_data = 8'hAB;
    logic tx_ready = 0, rx_ready = 0;
    logic parity_err = 0, framing_err = 0, overrun_err = 0;
	logic new_baud = 0;
    logic irq, irq_n;

    logic [7:0] temp;

    // Clock generation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always #(CLK_PERIOD / 2) clk = ~clk;

    // DUT instantiation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    axi_ui #(
        .DL_WIDTH(DL_WIDTH),
        .PSD_WIDTH(PSD_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
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
        .regs_out(regs_out),
        .wr_en(wr_en),
		.rd_en(rd_en),
		.rd_data(rd_data),
        .tx_ready(tx_ready),
		.rx_ready(rx_ready),
        .parity_err(parity_err),
		.framing_err(framing_err),
		.overrun_err(overrun_err),
		.new_baud(new_baud),
        .irq(irq),
		.irq_n(irq_n)
    );

    // Tasks ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    task automatic axi_write(input [2:0] addr, input [7:0] val);
        awaddr  = addr;
        awvalid = 1;
        wdata   = val;
        wvalid  = 1;
        bready  = 1;

        wait (awready && wready);
        @(posedge clk);
        awvalid = 0;
        wvalid  = 0;

        wait (bvalid);
        @(posedge clk);
        bready = 0;
    endtask

    task automatic axi_read(input [2:0] addr, output [7:0] val);
        araddr  = addr;
        arvalid = 1;
        rready  = 1;

        wait (arready);
        @(posedge clk);
        arvalid = 0;

        wait (rvalid);
        val = rdata[7:0];
        @(posedge clk);
        rready = 0;
    endtask

    // Test ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initial begin
        $display("Starting axi_ui_tb...");
        rst = 1;
        awvalid = 0; wvalid = 0; arvalid = 0; rready = 0; bready = 0;
        repeat (2) @(posedge clk);
        rst = 0;
        repeat (2) @(posedge clk);

        // Set interrupt enables
        axi_write(3'd1, 8'b0000_0111); // IER: enable all interrupts

        // Set LCR to normal mode (DLAB = 0)
        axi_write(3'd3, 8'h03); // LCR: 8-bit, 1 stop bit, no parity

        // Simulate RX ready
        rx_ready = 1;
        repeat (1) @(posedge clk);

        // Check IRQ
        if (irq !== 1) begin
			$display("IRQ should be asserted when RX is ready");
			$finish;
		end
        rx_ready = 0;
        repeat (1) @(posedge clk);

        // Read from RHR
        axi_read(3'd0, temp);
        $display("Read RHR = 0x%02x", temp);

        repeat (1) @(posedge clk);
        if (irq_n !== 1) begin
			$display("IRQ should be cleared after RHR read");
			$finish;
		end
		
        // === Check Default Reset Values ===
        axi_read(3'd3, temp);  // LCR
        if (temp !== 8'h03) begin
			$display("LCR default incorrect");
			$finish;
		end

        axi_read(3'd3, temp);  // DLL (via DLAB)
        axi_write(3'd3, 8'h83); // LCR.DLAB = 1
        axi_read(3'd0, temp);
        if (temp !== 8'h01) begin
			$display("DLL default incorrect");
			$finish;
		end

        // === DLAB Behavior ===
        axi_write(3'd0, 8'hAA); // DLL write
        axi_read(3'd0, temp);
        if (temp !== 8'hAA) begin
			$display("DLL write failed");
			$finish;
		end

        axi_write(3'd1, 8'h55); // DLM write
        axi_read(3'd1, temp);
        if (temp !== 8'h55) begin
			$display("DLM write failed");
			$finish;
		end

        // === Back to normal mode ===
        axi_write(3'd3, 8'h03); // DLAB = 0
        axi_write(3'd0, 8'hAB); // THR write
        if (!wr_en) begin
			$display("WR_EN not triggered for THR");
			$finish;
		end

        // === new_baud test ===
        axi_write(3'd3, 8'h83); // DLAB = 1
        axi_write(3'd0, 8'h11); // write DLL
        if (!new_baud)begin
			$display("new_baud not asserted");
			$finish;
		end
        @(posedge clk);

        // === RX ready -> rd_en
        axi_write(3'd3, 8'h03); // DLAB = 0
        rx_ready = 1;
        axi_read(3'd0, temp);
        if (!rd_en) begin
			$display("rd_en not asserted during RHR read");
			$finish;
		end
        rx_ready = 0;
        @(posedge clk);

        // === Interrupt Status Priority ===
        axi_write(3'd1, 8'h07); // Enable all IER
        parity_err = 1;
        @(posedge clk);
        axi_read(3'd2, temp); // ISR
        if (temp[4:0] !== 4'b01100) begin
			$display("ISR did not prioritize line status");
			$finish;
		end

        parity_err = 0;
        rx_ready   = 1;
        @(posedge clk);
        axi_read(3'd2, temp); // ISR
        if (temp[4:0] !== 4'b01000)begin
			$display("ISR did not handle RX ready");
			$finish;
		end

        rx_ready = 0;
        tx_ready = 1;
        @(posedge clk);
        axi_read(3'd2, temp); // ISR
        if (temp[4:0] !== 4'b00100) begin
			$display("ISR did not handle TX empty");
			$finish;
		end

        tx_ready = 0;
        @(posedge clk);
        axi_read(3'd2, temp); // ISR
        if (temp[4:0] !== 4'b00011) begin
			$display("ISR not cleared");
			$finish;
		end

        $display("AXI User Interface Tests Complete!");
        $finish;
    end

endmodule
