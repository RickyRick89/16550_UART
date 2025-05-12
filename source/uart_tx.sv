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

    // Types ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    typedef enum logic [2:0] {
        IDLE, START, DATA, PARITY, STOP
    } tx_state_t;


    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    tx_state_t state;

    logic [7:0] shift_reg;
    logic [3:0] bit_cnt;
    logic       parity_bit;
    logic       stop_phase;
    logic       tx_pending;
    logic       tx_active;


    // Assignments ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // TXD Output Drive
    assign txd =
        (state == START)  ? 1'b0 :
        (state == DATA)   ? shift_reg[0] :
        (state == PARITY) ? parity_bit :
                            1'b1;

    // TX Active Logic
    assign tx_busy = tx_active || tx_pending;

    // Baud Clock Enable
    assign enable_baud = tx_busy;

    // TX FSM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            shift_reg   <= 8'd0;
            bit_cnt     <= 0;
            parity_bit  <= 0;
            stop_phase  <= 0;
            tx_pending  <= 0;
            tx_active   <= 0;
        end else begin
            if (!tx_active && tx_start)
                tx_pending <= 1;

            if (tick) begin
                case (state)
                    IDLE: begin
                        if (tx_pending) begin
                            shift_reg  <= tx_data;
                            bit_cnt    <= 0;
                            parity_bit <= ^tx_data;
                            if (!parity_even) parity_bit <= ~parity_bit;
                            stop_phase <= 0;
                            tx_active  <= 1;
                            tx_pending <= 0;
                            state      <= START;
                        end
                    end

                    START: begin
                        state <= DATA;
                    end

                    DATA: begin
                        shift_reg <= {1'b0, shift_reg[7:1]};
                        bit_cnt <= bit_cnt + 1;
                        if (bit_cnt == data_bits - 1)
                            state <= (parity_en ? PARITY : STOP);
                    end

                    PARITY: begin
                        state <= STOP;
                    end

                    STOP: begin
                        if (stop_bits == 2'd2 && !stop_phase) begin
                            stop_phase <= 1;
                        end else begin
                            stop_phase <= 0;
                            tx_active  <= 0;
                            state      <= IDLE;
                        end
                    end
                endcase
            end
        end
    end

endmodule
