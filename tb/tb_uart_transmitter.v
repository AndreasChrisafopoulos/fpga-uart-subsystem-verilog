// Testbench for uart_transmitter – verifies serial output, timing, and busy flag operation
`timescale 1ns/1ps

module tb_uart_transmitter();

    reg clk;
    reg reset;
    reg [7:0] Tx_DATA;
    reg [2:0] baud_select;
    reg Tx_EN;
    reg Tx_WR;
    wire TxD;
    wire Tx_BUSY;

    // Device Under Test
    uart_transmitter uut (
        .reset(reset),
        .clk(clk),
        .Tx_DATA(Tx_DATA),
        .baud_select(baud_select),
        .Tx_EN(Tx_EN),
        .Tx_WR(Tx_WR),
        .TxD(TxD),
        .Tx_BUSY(Tx_BUSY)
    );

    // Clock generation: 100 MHz → 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin

        // Initialization
        reset = 1; 
        Tx_EN = 0; 
        Tx_WR = 0; 
        Tx_DATA = 8'b0; 
        baud_select = 3'b011;  // 9600 bps
        #20;
        reset = 0;

        // Enable UART transmitter
        Tx_EN = 1;

        //      - Send first byte -
        Tx_DATA = 8'b10100011; // example data byte
        Tx_WR = 1;
        #11000000;
        Tx_WR = 0;

        // Wait for transmission to complete
        wait (Tx_BUSY == 0);
        #100000;

        #11000000;

        //      - Send second byte -
        Tx_DATA = 8'b11001100;
        Tx_WR = 1;
        #11000000;
        Tx_WR = 0;

        // Wait for transmission to complete
        wait (Tx_BUSY == 0);
        #100000;

        $finish;
    end

endmodule
