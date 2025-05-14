`timescale 1ns/1ps
`include "../source/axi4_lite_pkg.sv"
`include "../source/uart_16550_regs_pkg.sv"

module uart_16550_tb;

    // Imports ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    import axi4_lite_pkg::*;
    import uart_16550_regs_pkg::*;

    // Parameters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    parameter CLK_PERIOD = 10;
    parameter DL_WIDTH = 16;
    parameter PSD_WIDTH = 4;

    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Clock and Reset
    logic clk = 0;
    logic rst;

    // AXI4-Lite
    axi_lite_addr_t awaddr, araddr;
    axi_lite_data_t wdata, rdata;
    axi_lite_strb_t wstrb = 4'b1111;
    axi_lite_resp_t bresp, rresp;
    logic awvalid, wvalid, bvalid, bready;
    logic arvalid, arready, rvalid, rready;
    logic awready, wready;

	logic [7:0] rx_val;
		
    // IRQs
    logic irq, irq_n;

    // Loopback wires
    logic rxd, txd;
	
	
    // Assignments ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    assign rxd = txd;

    // Clock Generation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always #(CLK_PERIOD / 2) clk = ~clk;

    // DUT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    uart_16550 #(
        .DL_WIDTH(DL_WIDTH),
        .PSD_WIDTH(PSD_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .irq(irq),
        .irq_n(irq_n),
        .awaddr(awaddr),
        .awvalid(awvalid),
        .awready(awready),
        .wdata(wdata),
        .wvalid(wvalid),
        .wready(wready),
        .wstrb(wstrb),
        .bvalid(bvalid),
        .bready(bready),
        .bresp(bresp),
        .araddr(araddr),
        .arvalid(arvalid),
        .arready(arready),
        .rdata(rdata),
        .rvalid(rvalid),
        .rready(rready),
        .rresp(rresp),
        .rxd(rxd),
        .txd(txd)
    );

    // Tasks ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

    // Main test ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initial begin
        $display("Starting UART 16550 testbench...");
        rst = 1;
        awvalid = 0; wvalid = 0; bready = 0; arvalid = 0; rready = 0;
        repeat (5) @(posedge clk);
        rst = 0;
        repeat (5) @(posedge clk);
		
		if (irq !== 0) begin
			$display("IRQ signal not zero at start");
			$finish;
		end

        // Configure UART (DLAB=1 to access DLL/DLM/PSD)
        axi_write(3'd3, 8'h83);  // LCR = DLAB=1, 8-bit
        axi_write(3'd0, 8'd213); // DLL
        axi_write(3'd1, 8'd2);   // DLM
        axi_write(3'd5, 8'd0);   // PSD
        axi_write(3'd3, 8'h03);  // LCR = DLAB=0, 8-bit

        // Enable RX interrupt
        axi_write(3'd1, 8'b0000_0101); // IER

        // Write byte to THR
        axi_write(3'd0, 8'hA5); // write to THR

        // Wait for interrupt
        wait (irq);
        $display("IRQ triggered!");

        // Wait for RX Ready
        axi_read(3'd0, rx_val); // read from RHR
        $display("Received: 0x%02x", rx_val);
        if (rx_val !== 8'hA5) begin
			$display("Loopback RX failed.");
			$finish;
		end

        repeat (2) @(posedge clk);
        if (irq) begin
			$display("IRQ should be cleared.");
			$finish;
		end

        $display("UART 16550 loopback test passed.");
        $finish;
    end

endmodule
