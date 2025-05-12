module uart_tx (
    input  logic        clk,
    input  logic        rst,

    // Transmit interface
    input  logic [7:0]  tx_data,
    input  logic        tx_start,     
    output logic        tx_busy,

    // Configuration
    input  logic [3:0]  data_bits,    
    input  logic        parity_en,
    input  logic        parity_even,
    input  logic [1:0]  stop_bits,    

    // Baud pulse
    input  logic        tick,

    // Output
    output logic        txd,
    output logic        enable_baud
);

endmodule
