`timescale 1ns/1ps

module uart_16550_regs_tb;

    import uart_16550_regs_pkg::*;

    uart_16550_regs_t regs;
	
	logic [7:0]  single_reg;

    initial begin
        $display("Starting UART register package test....");

        // Default values
        regs = uart_16550_default();
        if (regs.lcr.word_length !== 2'b11) begin
			$display("Default word_length incorrect");
			$finish;
		end
        if (regs.lsr.tx_empty !== 1'b1) begin
			$display("Default tx_empty incorrect");
			$finish;
		end
        if (regs.dll !== 8'h01) begin
			$display("Default DLL incorrect");
			$finish;
		end

        // Test write to THR (DLAB = 0)
        regs.lcr.dlab = 0;
        regs = uart_reg_write(regs, 3'd0, 8'hA5);
        if (regs.thr !== 8'hA5) begin
			$display("THR write failed");
			$finish;
		end

        // Test write to DLL (DLAB = 1)
        regs.lcr.dlab = 1;
        regs = uart_reg_write(regs, 3'd0, 8'h22);
        if (regs.dll !== 8'h22) begin
			$display("DLL write failed");
			$finish;
		end

        // Test read from RHR (DLAB = 0)
        regs.lcr.dlab = 0;
        regs.rhr = 8'hCC;
		single_reg = uart_reg_read(regs, 3'd0);
        if (single_reg !== 8'hCC) begin
			$display("RHR read failed");
			$finish;
		end

        // Test write to LCR
        regs = uart_reg_write(regs, 3'd3, 8'h5B);
        if (regs.lcr !== 8'h5B) begin
			$display("LCR write failed");
			$finish;
		end

        // Test read from LSR (DLAB = 0)
        regs.lcr.dlab = 0;
        regs.lsr.tx_empty = 0;
		single_reg = uart_reg_read(regs, 3'd5);
        if (single_reg[6] !== 1'b0) begin
			$display("LSR read failed");
			$finish;
		end

        // Test write to PSD (DLAB = 1)
        regs.lcr.dlab = 1;
        regs = uart_reg_write(regs, 3'd5, 8'h12);
        if (regs.psd !== 8'h12) begin
			$display("PSD write failed");
			$finish;
		end

        $display("All UART register tests passed.");
        $finish;
    end

endmodule
