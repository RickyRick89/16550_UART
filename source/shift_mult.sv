module shift_mult #(
  parameter MULTIPLICAND_WIDTH = 16,
  parameter MULTIPLIER_WIDTH = 8,
  localparam PRODUCT_WIDTH = MULTIPLICAND_WIDTH + MULTIPLIER_WIDTH,
  localparam type multiplicand_word_t = logic [MULTIPLICAND_WIDTH-1:0],
  localparam type multiplier_word_t = logic [MULTIPLIER_WIDTH-1:0],
  localparam type product_word_t = logic [PRODUCT_WIDTH-1:0]
) (
  input  multiplicand_word_t    multiplicand,
  input  multiplier_word_t    multiplier,
  input  logic     start,
  input  logic     clk,
  input  logic     rst_n,

  output product_word_t    product,
  output logic     busy
);

  typedef struct packed {
    product_word_t acc;
    product_word_t multiplicand; //This is product word type so we don't lose needed data when shifting.
    multiplier_word_t multiplier;
    logic  operating;
  } state_t;

  state_t current, next;

  always_ff @(posedge clk)
    current <= next;

  always_comb begin
    next = current;

    if (start) begin
      next.acc         = '0;
      next.multiplicand = multiplicand;
      next.multiplier   = multiplier;
	  if (multiplier > 0) next.operating = 1;
    end
    else if (next.operating) begin
      if (next.multiplier[0]) next.acc += next.multiplicand;

      next.multiplicand <<= 1;
      next.multiplier   >>= 1;

      if (next.multiplier == 0) next.operating = 0;
    end
	
    if (!rst_n) next = '0;
  end

  assign product = current.acc;
  assign busy    = current.operating;

endmodule
