// UART receiver datapath: performs 16× oversampling, mid-bit detection, bit counting,
// shifting, parity and stop-bit checking, driven by control signals from the FSM.

module uart_rx_datapath(
    input        clk,
    input        reset,
    input        sample_ENABLE,
    input        RxD_sync,

    input        reset_sample_cnt,
    input        reset_bit_cnt,
    input        shift_enable,
    input        parity_enable,
    input        stop_phase,

    output reg [7:0] Rx_DATA,
    output reg       Rx_VALID,
    output reg       Rx_FERROR,
    output reg       Rx_PERROR,

    output wire      sample_midbit,
    output wire      last_data_bit
);

    reg [3:0] sample_cnt;
    reg [3:0] bit_cnt;
    reg [7:0] rx_shift;

    // keeps parity while receiving data bits
    reg       parity_calc;

    assign sample_midbit = (sample_cnt == 4'd7);
    assign last_data_bit = (bit_cnt   == 4'd7);  
    // 0..7 data bits

    //SAMPLE COUNTER
    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
            sample_cnt      <= 0;
        else if (sample_ENABLE) 
        begin
            if (reset_sample_cnt)
                sample_cnt  <= 0;
            else if (sample_cnt == 4'd15)
                sample_cnt  <= 0;
            else
                sample_cnt  <= sample_cnt + 1;
        end
    end

    //BIT COUNTER, PARITY CALC
    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            bit_cnt         <= 0;
            parity_calc     <= 0;
        end
        else if (sample_ENABLE) 
        begin
           if (reset_bit_cnt) 
           begin
                bit_cnt     <= 0;
                parity_calc <=0;
            end
            else if (shift_enable) 
            begin
                bit_cnt     <= bit_cnt + 1;
                parity_calc <= parity_calc ^ RxD_sync;
            end
        end
    end


    //shift reg
    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
            rx_shift <= 0;
        else if (sample_ENABLE) 
        begin
            if (shift_enable) 
                rx_shift[bit_cnt] <= RxD_sync;
        end
    end

    //RX FERROR
    always @(posedge clk or posedge reset) 
    begin
        if (reset)
            Rx_FERROR <= 0;
        else if (sample_ENABLE && stop_phase)
            Rx_FERROR <= ~RxD_sync;
    end

    //PERROR
    always @(posedge clk or posedge reset) 
    begin
        if (reset)
            Rx_PERROR <= 0;
        else if (sample_ENABLE && parity_enable)
            Rx_PERROR <= (parity_calc != RxD_sync);
    end

    //RX DATA
    always @(posedge clk or posedge reset) 
    begin
        if (reset)
            Rx_DATA <= 0;
        else if (sample_ENABLE && stop_phase)
            Rx_DATA <= rx_shift;
    end

    //VALID FLAG
    always @(posedge clk or posedge reset) 
    begin
        if (reset)
            Rx_VALID <= 0;
        else if (sample_ENABLE ) 
        begin
            if (stop_phase) 
            begin
                if (~RxD_sync || Rx_PERROR)
                    Rx_VALID <= 0;
                else
                    Rx_VALID <= 1;
            end  
            else if (reset_bit_cnt)
                Rx_VALID     <= 0;
        end 
    end


endmodule
