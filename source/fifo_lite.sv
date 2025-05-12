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

    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    logic [WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
    logic [ADDR_WIDTH:0]   count;

    // Assignments ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    assign empty = (count == 0);
    assign full  = (count == DEPTH);

    // Read/Write Logic ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr   <= 0;
            rd_ptr   <= 0;
            count    <= 0;
            rd_data  <= 0;
            rd_valid <= 0;
        end else begin
            logic do_write = wr_en && !full;
            logic do_read  = rd_en && !empty;

            // Write data
            if (do_write) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1;
            end

            // Read data
            if (do_read) begin
                rd_data <= mem[rd_ptr];
                rd_ptr  <= rd_ptr + 1;
                rd_valid <= 1;
            end else begin
                rd_valid <= 0;
            end

            // Adjust count
            case ({do_write, do_read})
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                default: count <= count;
            endcase
        end
    end

endmodule
