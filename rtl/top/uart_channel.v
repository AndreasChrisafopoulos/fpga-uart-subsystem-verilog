// Top-level UART channel combining transmitter and receiver modules,
// with internal wiring from transmitter output to receiver input.

module uart_channel (
    input        clk,
    input        reset,
    input  [2:0] baud_select,

    // Transmitter side
    input        Tx_EN,
    input        Tx_WR,
    input  [7:0] Tx_DATA,
    output       Tx_BUSY,

    // Receiver side
    output [7:0] Rx_DATA,
    output       Rx_VALID,
    output       Rx_FERROR,
    output       Rx_PERROR
);


    // Internal UART line wire
    wire TxD_line;
    wire Tx_BUSY_wire;


    // Instantiate transmitter
    uart_transmitter TX (
        .reset(reset),
        .clk(clk),
        .Tx_DATA(Tx_DATA),
        .baud_select(baud_select),
        .Tx_EN(Tx_EN),
        .Tx_WR(Tx_WR),

        .TxD(TxD_line),
        .Tx_BUSY(Tx_BUSY_wire)
    );


    // Instantiate receiver
    uart_receiver RX (
        .reset(reset),
        .clk(clk),
        .baud_select(baud_select),
        .Rx_EN(Tx_BUSY_wire),          
        .RxD(TxD_line),        // connect TX -> RX

        .Rx_DATA(Rx_DATA),
        .Rx_FERROR(Rx_FERROR),
        .Rx_PERROR(Rx_PERROR),
        .Rx_VALID(Rx_VALID)
    );

    assign Tx_BUSY = Tx_BUSY_wire;

endmodule
