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

    // Types ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    typedef enum logic [2:0] {
        IDLE, START, DATA, PARITY, STOP
    } rx_state_t;


    // Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    rx_state_t state, next_state;

    logic [3:0] bit_count;
    logic [3:0] sample_count;
    logic [7:0] shift_reg;
    logic       sampled_parity;
    logic       parity_bit;
    logic       stop_sampled;
    logic       stop_phase;

    // Falling Edge Detection ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            enable_sample <= 0;
        else if (state == IDLE && !rxd)
            enable_sample <= 1;
        else if (state == STOP && next_state == IDLE)
            enable_sample <= 0;
    end

    // FSM ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    always_ff @(posedge clk)
        state <= next_state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            next_state      <= IDLE;
            bit_count       <= 0;
            sample_count    <= 0;
            shift_reg       <= 0;
            data_ready      <= 0;
            parity_err      <= 0;
            framing_err     <= 0;
            stop_sampled    <= 0;
            stop_phase      <= 0;
            data_out        <= 0;
            parity_bit      <= 0;
            sampled_parity  <= 0;
        end else if (sample_tick) begin

            case (state)
                IDLE: begin
                    bit_count     <= 0;
                    sample_count  <= 0;
                    if (enable_sample)
                        next_state <= START;
                    else
                        next_state <= IDLE;
                end

                START: begin
                    if (sample_count == 7) begin
                        if (!rxd) begin
                            sample_count <= 0;
                            next_state <= DATA;
                        end else begin
                            next_state <= IDLE;
                        end
                    end else begin
                        sample_count <= sample_count + 1;
                        next_state <= START;
                    end
                end

                DATA: begin
                    if (sample_count == 15) begin
                        shift_reg <= {rxd, shift_reg[7:1]};
                        sample_count <= 0;
                        bit_count <= bit_count + 1;

                        if (bit_count == data_bits - 1)
                            next_state <= (parity_en ? PARITY : STOP);
                        else
                            next_state <= DATA;
                    end else begin
                        sample_count <= sample_count + 1;
                        next_state <= DATA;
                    end
                end

                PARITY: begin
                    if (sample_count == 15) begin
                        sampled_parity <= rxd;
                        sample_count <= 0;
                        next_state <= STOP;
                    end else begin
                        sample_count <= sample_count + 1;
                        next_state <= PARITY;
                    end
                end

                STOP: begin
                    if (sample_count == 15) begin
                        sample_count <= 0;
                        stop_sampled <= rxd;
                        stop_phase <= ~stop_phase;

                        if ((stop_bits && stop_phase == 1) || !stop_bits) begin
                            data_out <= shift_reg;

                            if (stop_bits)
                                framing_err <= ~(stop_sampled & rxd);
                            else
                                framing_err <= ~rxd;

                            if (parity_en) begin
                                parity_bit = 0;
                                for (int i = 0; i < 8; i++) begin
                                    if (i < data_bits)
                                        parity_bit ^= shift_reg[i];
                                end
                                
                                if (!parity_even)
                                    parity_bit = ~parity_bit;
                                
                                parity_err <= (sampled_parity !== parity_bit);
                            end else begin
                                parity_err <= 0;
                            end

                            data_ready   <= 1;
                            next_state   <= IDLE;
                            stop_phase   <= 0;
                            stop_sampled <= 0;
                        end else begin
                            next_state <= STOP;
                        end
                    end else begin
                        sample_count <= sample_count + 1;
                        next_state <= STOP;
                    end
                end
            endcase
        end else begin
            data_ready <= 0;
        end
    end

endmodule
