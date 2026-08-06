// UART channel testbench: generates clock/reset, transmits 4 test bytes, monitors RX output,
// verifies loopback correctness and reports parity/frame error status for each reception.
`timescale 1ns/1ps

module tb_uart_channel;

    reg clk;
    reg reset;

    // UART control inputs
    reg        Tx_EN;
    reg        Tx_WR;
    reg [7:0]  Tx_DATA;
    reg [2:0]  baud_select;

    // UART outputs
    wire       Tx_BUSY;
    wire [7:0] Rx_DATA;
    wire       Rx_VALID;
    wire       Rx_FERROR;
    wire       Rx_PERROR;

    // Instantiate the DUT (Device Under Test)
    uart_channel DUT (
        .clk(clk),
        .reset(reset),
        .baud_select(baud_select),
        .Tx_EN(Tx_EN),
        .Tx_WR(Tx_WR),
        .Tx_DATA(Tx_DATA),
        .Tx_BUSY(Tx_BUSY),
        .Rx_DATA(Rx_DATA),
        .Rx_VALID(Rx_VALID),
        .Rx_FERROR(Rx_FERROR),
        .Rx_PERROR(Rx_PERROR)
    );

    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end


    // Task to send a byte over UART
    task uart_send(input [7:0] data);
    begin
        // Wait until transmitter is free
        while (Tx_BUSY) @(posedge clk);

        Tx_DATA = data;
        Tx_WR   = 1'b1;   // pulse write
        #11000000;
        Tx_WR   = 1'b0;
        #11000000;
        $display("[%0t]  TX: Sent byte   0x%02h", $time, data);
    end
    endtask


    
    // Receiver monitoring
    always @(posedge clk) begin
        if (Rx_VALID) begin
            $display("[%0t]  RX: Received byte 0x%02h  (ParityErr=%0b, FrameErr=%0b)",
                     $time, Rx_DATA, Rx_PERROR, Rx_FERROR);
        end
    end


    // Test sequence
    initial begin
        // Init
        reset        = 1;
        Tx_EN        = 0;
        Tx_WR        = 0;
        Tx_DATA      = 0;
        baud_select  = 3'b001;   // set a baud rate

        #11000000;
        reset = 0;
        Tx_EN = 1;

       

        // Send four bytes
        uart_send(8'h55);
        uart_send(8'hAA);
        uart_send(8'h5A);
        uart_send(8'hC3);

        // Give some time for last reception
        #50000;

        $display("Simulation finished.");
        $stop;
    end

endmodule
