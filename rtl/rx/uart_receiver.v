// UART Receiver Top Module
// Combines synchronizer, baud controller, FSM, and datapath to sample and decode
// serial UART frames, producing received data along with parity and framing error flags.
module uart_receiver(
    input        reset,
    input        clk,
    input  [2:0] baud_select,
    input        Rx_EN,
    input        RxD,

    output [7:0] Rx_DATA,
    output       Rx_FERROR,
    output       Rx_PERROR,
    output       Rx_VALID
);

    // Synchronizer   
    wire RxD_sync;
    synchronizer sync_unit (
        .clk(clk),
        .reset(reset),
        .RxD(RxD),
        .RxD_sync(RxD_sync)
    );

    // Baud Controller
    wire sample_ENABLE;
    baud_controller baud_ctrl (
        .reset(reset),
        .clk(clk),
        .baud_select(baud_select),
        .sample_ENABLE(sample_ENABLE)
    );


    // Datapath
    wire sample_midbit, last_data_bit;

    wire reset_sample_cnt, reset_bit_cnt;
    wire shift_enable, parity_enable, stop_phase;

    uart_rx_datapath datapath (
        .clk(clk),
        .reset(reset),
        .sample_ENABLE(sample_ENABLE),
        .RxD_sync(RxD_sync),

        .reset_sample_cnt(reset_sample_cnt),
        .reset_bit_cnt(reset_bit_cnt),
        .shift_enable(shift_enable),
        .parity_enable(parity_enable),
        .stop_phase(stop_phase),
    
        .Rx_DATA(Rx_DATA),
        .Rx_VALID(Rx_VALID),
        .Rx_FERROR(Rx_FERROR),
        .Rx_PERROR(Rx_PERROR),

        .sample_midbit(sample_midbit),
        .last_data_bit(last_data_bit)
    );


    // FSM
    uart_rx_fsm fsm (
        .clk(clk),
        .reset(reset),
        .Rx_EN(Rx_EN),
        .RxD_sync(RxD_sync),
        .sample_ENABLE(sample_ENABLE),
        .sample_midbit(sample_midbit),
        .last_data_bit(last_data_bit),

        .reset_sample_cnt(reset_sample_cnt),
        .reset_bit_cnt(reset_bit_cnt),
        .shift_enable(shift_enable),
        .parity_enable(parity_enable),
        .stop_phase(stop_phase)
    );

endmodule
