// Testbench for uart_channel_display: sends 4 bytes through UART 
// and verifies 7-segment display output behavior.

`timescale 1ns/1ps

module tb_uart_channel_display();

    reg clk = 0;
    reg reset = 1;
    reg Tx_EN = 1;
    reg Tx_WR = 0;
    reg [7:0] Tx_DATA;
    reg [2:0] baud_select = 3'b010; // example baud

    wire Tx_BUSY;
    wire Rx_FERROR, Rx_PERROR;
    wire an3, an2, an1, an0;
    wire a, b, c, d, e, f, g, dp;

    // Instantiate DUT
    uart_channel_display DUT(
        .clk(clk),
        .reset(reset),
        .baud_select(baud_select),

        .Tx_EN(Tx_EN),
        .Tx_WR(Tx_WR),
        .Tx_DATA(Tx_DATA),
        .Tx_BUSY(Tx_BUSY),

        .Rx_FERROR(Rx_FERROR),
        .Rx_PERROR(Rx_PERROR),

        .an3(an3),
        .an2(an2),
        .an1(an1),
        .an0(an0),
        .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
        .dp(dp)
    );

    // Generate 100MHz clock
    always #5 clk = ~clk;

    task send_byte(input [7:0] B);
    begin
        // wait until transmitter is free
             while (Tx_BUSY) @(posedge clk);

        Tx_DATA = B;
        Tx_WR   = 1'b1;   // pulse write
        #11000000;
        Tx_WR   = 1'b0;
        #11000000;
    end
    endtask

    initial begin
        // Reset
        #100;
        reset = 0;
        Tx_EN=1;
        Tx_WR=0;
        #11000000;
        // Send 4 characters
        send_byte(8'h12);
        send_byte(8'h34);
        send_byte(8'hAB);
        send_byte(8'hFE);

        // Wait a bit
        #50000;

        $finish;
    end

endmodule
