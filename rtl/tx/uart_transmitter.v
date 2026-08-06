// UART transmitter module: handles debouncing, baud generation, FSM control,
// bit-timing, and serialization of 8-bit data with parity.

module uart_transmitter (
    input reset, clk,
    input [7:0] Tx_DATA,
    input [2:0] baud_select,
    input Tx_EN,
    input Tx_WR,
    output reg TxD,
    output reg Tx_BUSY
);

    wire Tx_sample_ENABLE;
    wire Tx_WR_clean;

    reg [3:0] sample_count;   // 0–15
    reg [3:0] bit_index;      // 0–11
    reg [9:0] tx_shift_reg;  // start + data + parity
    

    //      - Debouncer & Baud Controller -
    debouncer db_Tx_WR (
        .clk(clk),
        .noisy_btn(Tx_WR),
        .btn_pulse(Tx_WR_clean)
    );

    baud_controller baud_controller_tx_inst(
        .reset(reset),
        .clk(clk),
        .baud_select(baud_select),
        .sample_ENABLE(Tx_sample_ENABLE)
    );


    //      - FSM -
    parameter IDLE = 2'b00;
    parameter LOAD = 2'b01;
    parameter SEND = 2'b10;
    parameter DONE = 2'b11;

    reg [1:0] current_state, next_state;
    reg reset_bit_cnt;
    reg reset_sample_cnt;
    reg load_enable;
    reg send_enable;
    reg done_sending;

    //next state logic
    always @(current_state or Tx_WR_clean or Tx_EN or bit_index ) 
    begin
        next_state = current_state;
        case (current_state)
            IDLE:begin
                if (Tx_WR_clean && Tx_EN) next_state = LOAD;
                else next_state = IDLE;
            end
            LOAD: next_state = SEND;
            SEND:begin
                if (bit_index == 10) next_state = DONE;
                else next_state = SEND;
            end
            DONE: begin
                if (bit_index == 11) next_state = IDLE;
                else next_state = DONE;
            end
            default: next_state = IDLE;
        endcase
    end

    //control-signals generation
    always @(*) 
    begin
        // defaults
        reset_sample_cnt = 0;
        reset_bit_cnt    = 0;
        load_enable      = 0;
        send_enable      = 0;
        done_sending     = 0;

        case (current_state)

            IDLE: begin
                reset_sample_cnt = 1;
                //reset_bit_cnt    = 1;
            end

            LOAD: begin
                load_enable      = 1;
                reset_bit_cnt    = 1;
                reset_sample_cnt = 1;
            end

            SEND: begin
                if (Tx_sample_ENABLE && sample_count == 15)
                    send_enable = 1;
                    
            end

            DONE: begin
                if (Tx_sample_ENABLE && sample_count == 15)
                    done_sending = 1;
            end
        endcase
    end

    //state reg
    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
            current_state <= IDLE;
        else    
            current_state <= next_state;
    end
    
    //output logic
    always @(current_state or bit_index or tx_shift_reg) 
    begin
        TxD = 1'b1;
        Tx_BUSY = 1'b0;

        case (current_state)
            IDLE: begin
                TxD     = 1'b1;
                Tx_BUSY = 1'b0;
            end
            LOAD: begin
                Tx_BUSY = 1'b1;
                TxD     = 1'b1;
            end
            SEND: begin
                Tx_BUSY = 1'b1;
                TxD     = tx_shift_reg[bit_index];
            end
            DONE: begin
                Tx_BUSY = 1'b1;
                TxD     = 1'b1;
            end
            default: begin
                TxD     = 1'b1;
                Tx_BUSY = 1'b0;
            end
        endcase
    end

    //      -DATAPATH-
    //bit index-cnt
    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
            bit_index  <= 0;
        else if(reset_bit_cnt)
            bit_index  <= 0;
        else if(send_enable || done_sending)
            bit_index  <= bit_index + 1;
    end

    //sample counter
    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
            sample_count  <= 0;
        else if (reset_sample_cnt)
            sample_count  <= 0;
        else if (Tx_sample_ENABLE) 
        begin
                if (sample_count == 15) 
                    sample_count <= 0;
                else
                    sample_count <= sample_count + 1;
        end
    end
     
   //load data
    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
            tx_shift_reg  <= 0;
        else if (load_enable)
            tx_shift_reg  <= {^Tx_DATA, Tx_DATA, 1'b0};
    end

endmodule
