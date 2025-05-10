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

endmodule
