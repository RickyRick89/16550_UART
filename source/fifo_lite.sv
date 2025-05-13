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

    // Internal storage and pointers
    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
    logic [ADDR_WIDTH:0]   count;

    // Status flags
    assign empty = (count == 0);
    assign full  = (count == DEPTH);
	
	
    // Sequential logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr   = 0;
            rd_ptr   = 0;
            count    = 0;
            rd_data  = '0;
            rd_valid = 0;
        end else begin
            rd_valid = 0;

            // Write operation
            if (wr_en && !full) begin
                mem[wr_ptr] = wr_data;
                wr_ptr = wr_ptr + 1;
            end

            // Read operation
            if (rd_en && !empty) begin
                rd_data  = mem[rd_ptr];
                rd_ptr   = rd_ptr + 1;
                rd_valid = 1;
            end

            // Count update
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count = count + 1;
                2'b01: count = count - 1;
                default: count = count;
            endcase
        end
    end

endmodule
