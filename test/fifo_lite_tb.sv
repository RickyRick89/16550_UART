`timescale 1ns/1ps

module fifo_lite_tb;

    // Parameters ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    parameter WIDTH = 8;
    parameter DEPTH = 16;
    parameter CLK_FREQ = 100_000_000;
    parameter CLK_PERIOD = 1_000_000_000 / CLK_FREQ;
    localparam ADDR_WIDTH = $clog2(DEPTH);

    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    logic clk = 0;
    logic rst;

    logic wr_en, rd_en;
    logic [WIDTH-1:0] wr_data, rd_data;
    logic rd_valid;
    logic empty, full;
	
	logic [ADDR_WIDTH-1:0] wr_ptr;
    logic [WIDTH-1:0] prev_rd_data;

    // Instantiate DUT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    fifo_lite #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .rd_valid(rd_valid),
        .empty(empty),
        .full(full)
    );

    // Clock generation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    initial begin
        $display("Starting FIFO Testbench...");
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        @(posedge clk);
        rst = 0;

        // Write until full
        for (int i = 0; i < DEPTH; i++) begin
            wr_data = i;
            wr_en = 1;
            @(posedge clk);
        end
        wr_en = 0;

        if (full !== 1) begin
			$display("ERROR: FIFO should be full after writing %0d entries", DEPTH);
			$finish;
		end

        // Attempt to write while full
		wr_ptr = dut.wr_ptr;
        wr_data = 8'hFF;
        wr_en = 1;
        @(posedge clk);
        wr_en = 0;
        if (dut.wr_ptr !== wr_ptr) begin
			$display("ERROR: FIFO not full when it should be");
			$finish;
		end

        // Read one word
        rd_en = 1;
        @(posedge clk);
        if (rd_valid !== 1) begin
			$display("ERROR: Expected valid read");
			$finish;
		end
		prev_rd_data = rd_data;

        // Pause
        rd_en = 0;
        repeat (2) @(posedge clk);
		if (rd_data !== prev_rd_data) begin
			$display("ERROR: Read value not held. Previous value = 0x%02x. Current value = 0x%02x.", prev_rd_data, rd_data);
			$finish;
		end

        // Continue reading remaining
        for (int i = 1; i < DEPTH; i++) begin
            rd_en = 1;
            @(posedge clk);
            if (rd_valid !== 1) begin
				$display("ERROR: Expected rd_valid during read");
				$finish;
			end
        end
        rd_en = 0;

        // Confirm empty
        if (empty !== 1) begin
            $display("ERROR: FIFO should be empty after all reads");
			$finish;
		end

        // Read while empty
        rd_en = 1;
        @(posedge clk);
        rd_en = 0;
        if (rd_valid !== 0 ) begin
			$display("ERROR: rd_valid should not be high while FIFO is empty");
			$finish;
		end

        $display("FIFO tests complete!");
        $finish;
    end

endmodule
