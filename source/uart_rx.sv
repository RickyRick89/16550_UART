module uart_rx (
    input  logic        clk,
    input  logic        rst,
    input  logic        rxd,
    input  logic        sample_tick,
    input  logic        stop_bits,
    input  logic        parity_en,
    input  logic        parity_even,
    input  logic [3:0]  data_bits,
    input  logic        enable,

    output logic        enable_sample,
    output logic        data_ready,
    output logic [7:0]  data_out,
    output logic        parity_err,
    output logic        framing_err
);
endmodule
