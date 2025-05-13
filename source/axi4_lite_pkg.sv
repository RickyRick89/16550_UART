`timescale 1 ns/10 ps

package axi4_lite_pkg;

    // Types ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//ADDR:
	localparam int AXI_ADDR_WIDTH = 32;
	typedef logic [AXI_ADDR_WIDTH - 1:0] axi_lite_addr_t;

	// DATA:
	localparam int AXI_DATA_WIDTH = 32;
	typedef logic [AXI_ADDR_WIDTH - 1:0] axi_lite_data_t;

	// STRB:
	typedef logic [(AXI_DATA_WIDTH / 8) - 1:0] axi_lite_strb_t;

	// PROT:
	localparam int AXI_PROT_WIDTH = 3;
	typedef logic [AXI_PROT_WIDTH - 1:0] axi_lite_prot_t;
	localparam AXI_PROT_UNPRIVILEGED_ACCESS = 'b000;
	localparam AXI_PROT_PRIVILEGED_ACCESS   = 'b001;

	localparam AXI_PROT_SECURE_ACCESS     = 'b000;
	localparam AXI_PROT_NON_SECURE_ACCESS = 'b010;

	localparam AXI_PROT_DATA_ACCESS        = 'b000;
	localparam AXI_PROT_INSTRUCTION_ACCESS = 'b100;

	// RESP:
	localparam int AXI_RESP_WIDTH = 2;
	typedef logic [AXI_RESP_WIDTH - 1:0] axi_lite_resp_t;

	typedef enum {
	  AXI_RESP_OKAY,
	  AXI_RESP_EXOKAY, // This is not supported by AXI4-Lite.
	  AXI_RESP_SLVERR,
	  AXI_RESP_DECERR
	} axi_lite_resp_enum;

endpackage : axi4_lite_pkg
