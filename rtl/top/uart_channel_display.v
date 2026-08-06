// UART channel top-level wrapper: connects uart_channel with a 7-segment LED driver to display
// received bytes and error flags (parity/frame) on a 4-digit display.

module uart_channel_display (
    input        clk,
    input        reset,
    input  [2:0] baud_select,

    // Transmitter side
    input        Tx_EN,
    input        Tx_WR,
    input  [7:0] Tx_DATA,
    output       Tx_BUSY,

    output       Rx_FERROR,
    output       Rx_PERROR,

    output an3, an2, an1, an0, 
    output a, b, c, d, e, f, g, dp // 7-segment outputs
);
    wire [7:0] data;
    wire valid;

    uart_channel channel_inst(
        .clk(clk),
        .reset(reset),
        .baud_select(baud_select),
        .Tx_EN(Tx_EN),
        .Tx_WR(Tx_WR),
        .Tx_DATA(Tx_DATA),

        .Tx_BUSY(Tx_BUSY),

        .Rx_DATA(data),
        .Rx_PERROR(Rx_PERROR),
        .Rx_FERROR(Rx_FERROR),
        .Rx_VALID(valid)
    );

    TwoDigitLEDdriver disp_inst(
        .clk(clk),
        .reset(reset),
        .data(data),
        .valid(valid),

        .an1(an1),
        .an0(an0),
        .an2(an2),
        .an3(an3),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .dp(dp)
    );



endmodule