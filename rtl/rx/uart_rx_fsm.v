// UART Receiver Control FSM (Mealy machine): Generates timing and control pulses
// for start-bit validation, data shifting, parity checking, and stop-bit detection
// based on state and mid-bit sampling inputs.
module uart_rx_fsm(
    input        clk,
    input        reset,
    input        Rx_EN,
    input        RxD_sync,
    input        sample_ENABLE,
    input        sample_midbit,
    input        last_data_bit,

    output reg   reset_sample_cnt,
    output reg   reset_bit_cnt,
    output reg   shift_enable,
    output reg   parity_enable, 
    output reg   stop_phase
);

    localparam IDLE     = 3'd0;
    localparam START    = 3'd1;
    localparam DATA     = 3'd2;
    localparam PARITY   = 3'd3;
    localparam STOP     = 3'd4;

    reg [2:0] state, next_state;
    
    // STATE REGISTER
    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            state <= IDLE;
        end
        else if (sample_ENABLE)
            state <= next_state;
    end

    // NEXT-STATE LOGIC
    always @(*) 
    begin
        next_state = state;

        case (state)
            IDLE:
                if (Rx_EN && RxD_sync == 1'b0)
                    next_state = START;

            START:
                if (sample_midbit)
                    next_state = DATA;

            DATA:
                if (last_data_bit && sample_midbit)
                    next_state = PARITY;
            
            PARITY:
                if (sample_midbit)
                    next_state = STOP;

            STOP:
                if (sample_midbit )
                    next_state = IDLE;
        endcase
    end

    // CONTROL DECODE
    always @(*) 
    begin
        // defaults
        reset_sample_cnt = 0;
        reset_bit_cnt    = 0;
        shift_enable     = 0;
        parity_enable    = 0;
        stop_phase       = 0;

        case (state)

            IDLE: begin
                reset_sample_cnt = 1;
            end

            START: begin
                if (sample_midbit)
                    reset_bit_cnt = 1;
            end

            DATA: begin
                if (sample_midbit)
                    shift_enable = 1;
            end

            PARITY: begin
                if (sample_midbit)
                    parity_enable = 1;
            end

            STOP: begin
                if (sample_midbit) 
                        stop_phase   = 1;
            end

        endcase
    end

endmodule
