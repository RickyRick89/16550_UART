module fifo_lite #(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
    localparam ADDR_WIDTH = $clog2(DEPTH)
)(
    input  logic              clk,
    input  logic              rst,

    // In/Out interface
    input  logic              wr_en,
    input  logic [WIDTH-1:0]  wr_data,
    input  logic              rd_en,
    output logic [WIDTH-1:0]  rd_data,
    output logic              rd_valid,

    // Status Outputs
    output logic              empty,
    output logic              full
);

    logic [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
	
endmodule
