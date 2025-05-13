`timescale 1 ns/10 ps

package uart_16550_regs_pkg;

    // Types ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	typedef struct packed {
	
		// 0x0 - RHR/THR (RW)
		logic [7:0] rhr;
		logic [7:0] thr;

		// 0x1 - Interrupt Enable Register (RW)
		struct packed {
			logic       dma_tx_end_int_en;
			logic       dma_rx_end_int_en;
			logic [1:0] reserved_ier;
			logic       modem_status_int_en;
			logic       rx_line_status_int_en;
			logic       thr_empty_int_en;
			logic       data_ready_int_en;
		} ier;

		// 0x2 - Interrupt Status Register (R)
		struct packed {
			logic [1:0] fifos_enabled;
			logic       dma_tx_end_int_status;
			logic       dma_rx_end_int_status;
			logic [3:0] int_id;
			logic       int_status;
		} isr;

		// 0x3 - FIFO Control Register (W)
		struct packed {
			logic [1:0] rx_trigger_level;
			logic  		reserved_fcr;
			logic       dma_end_en;
			logic       dma_mode;
			logic       tx_fifo_reset;
			logic       rx_fifo_reset;
			logic       fifo_en;
		} fcr;

		// 0x4 - Line Control Register (RW)
		struct packed {
			logic       dlab;
			logic       set_break;
			logic       force_parity;
			logic       even_parity;
			logic       parity_en;
			logic       stop_bits;
			logic [1:0] word_length;
		} lcr;

		// 0x5 - Modem Control Register (RW)
		struct packed {
			logic [2:0] reserved_mcr;
			logic       loopback;
			logic       out2_int_en;
			logic       out1;
			logic       rts;
			logic       dtr;
		} mcr;

		// 0x6 - Line Status Register (R)
		struct packed {
			logic       fifo_err;
			logic       tx_empty;
			logic       thr_empty;
			logic       break_int;
			logic       framing_err;
			logic       parity_err;
			logic       overrun_err;
			logic       data_ready;
		} lsr;

		// 0x7 - Modem Status Register (R)
		struct packed {
			logic       cd;
			logic       ri;
			logic       dsr;
			logic       cts;
			logic       delta_cd;
			logic       trailing_edge_ri;
			logic       delta_dsr;
			logic       delta_cts;
		} msr;

		// 0x8 - Scratch Register (RW)
		logic [7:0] spr;

		// DLAB = 1 Registers ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// 0x0 - Divisor Latch Low (DLL)
		logic [7:0] dll;

		// 0x1 - Divisor Latch High (DLM)
		logic [7:0] dlm;

		// 0x5 - Prescaler Division Register (PSD)
		logic [7:0] psd;

	} uart_16550_regs_t;

	
    // Functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	function automatic uart_16550_regs_t uart_16550_default();
		
		uart_16550_default = '{default: 0};  // All fields to zero by default

		// Standard reset values
		uart_16550_default.lcr.word_length 	= 2'b11;	// 8-bit word length
		uart_16550_default.lsr.tx_empty 	= 1'b1;		// Defualt tx empty status
		uart_16550_default.lsr.thr_empty 	= 1'b1;		// Defualt Transmitter Holding Register empty status
		uart_16550_default.dll 				= 8'h01;	// Default divisor LSB
		uart_16550_default.dlm 				= 8'h00;	// Default divisor MSB
		uart_16550_default.psd 				= 8'h00;	// Default prescaler

	endfunction
	
	function automatic logic [7:0] uart_reg_read(
		input uart_16550_regs_t regs,
		input logic [2:0] addr
	);
		case (addr)
			3'd0: begin
				if (regs.lcr.dlab)
					uart_reg_read = regs.dll;
				else 
					uart_reg_read = regs.rhr;
			end
			3'd1: begin
				if (regs.lcr.dlab)
					uart_reg_read = regs.dlm;
				else
					uart_reg_read = regs.ier;
			end
			3'd2: uart_reg_read = regs.isr;
			3'd3: uart_reg_read = regs.lcr;
			3'd4: uart_reg_read = regs.mcr;
			3'd5: begin
				if (regs.lcr.dlab)
					uart_reg_read = regs.psd;
				else
					uart_reg_read = regs.lsr;
			end
			3'd6: uart_reg_read = regs.msr;
			3'd7: uart_reg_read = regs.spr;
			default: uart_reg_read = 8'hXX;
		endcase
	endfunction

	function automatic uart_16550_regs_t uart_reg_write(
		input uart_16550_regs_t regs_in,
		input logic [2:0] addr,
		input logic [7:0] wr_data
	);
		uart_16550_regs_t regs = regs_in;
		case (addr)
			3'd0:  begin
				if (regs.lcr.dlab) 
					regs.dll = wr_data;
				else
					regs.thr = wr_data;
			end
			3'd1: begin
				if (regs.lcr.dlab)
					regs.dlm = wr_data;
				else
					regs.ier = wr_data;
			end
			3'd2: regs.fcr = wr_data;
			3'd3: regs.lcr = wr_data;
			3'd4: regs.mcr = wr_data;
			3'd5:  begin
				if (regs.lcr.dlab)
					regs.psd = wr_data;
				// else	Do nothing
			end
			3'd6: regs.spr = wr_data;
			3'd7: regs.spr = wr_data;
			default: ; // ignore
		endcase
		return regs;
	endfunction



endpackage : uart_16550_regs_pkg
