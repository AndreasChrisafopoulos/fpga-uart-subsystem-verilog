// Testbench for the UART receiver: produces oversampled UART frames to test
// valid reception, parity error detection and framing error handling.

`timescale 1ns/1ps

module tb_uart_receiver;

    reg clk;
    reg reset;
    reg Rx_EN;
    reg RxD;
    reg [2:0] baud_select;

    wire [7:0] Rx_DATA;
    wire Rx_VALID;
    wire Rx_PERROR;
    wire Rx_FERROR;

    // Instantiate DUT
    uart_receiver uut (
        .clk(clk),
        .reset(reset),
        .Rx_EN(Rx_EN),
        .RxD(RxD),
        .baud_select(baud_select),
        .Rx_DATA(Rx_DATA),
        .Rx_VALID(Rx_VALID),
        .Rx_PERROR(Rx_PERROR),
        .Rx_FERROR(Rx_FERROR)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    wire sample_ENABLE = uut.sample_ENABLE;

    integer bit_idx;
    reg [7:0] test_byte;


    // TASK 1 – normal byte (correct parity & correct stop bit)
    task send_ok_byte(input [7:0] value);
        begin
            // Start bit
            RxD <= 0;
            repeat (16) @(posedge sample_ENABLE);

            // Data bits
            for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) begin
                RxD <= value[bit_idx];
                repeat (16) @(posedge sample_ENABLE);
            end

            // Correct parity bit
            RxD <= ^value;
            repeat (16) @(posedge sample_ENABLE);

            // Correct stop bit
            RxD <= 1;
            repeat (16) @(posedge sample_ENABLE);
        end
    endtask


    // TASK 2 – parity error (wrong parity, correct stop bit)
    task send_parity_error(input [7:0] value);
        begin
            RxD <= 0;
            repeat (16) @(posedge sample_ENABLE);

            for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) begin
                RxD <= value[bit_idx];
                repeat (16) @(posedge sample_ENABLE);
            end

            // Wrong parity bit
            RxD <= ~(^value);
            repeat (16) @(posedge sample_ENABLE);

            // Correct stop bit
            RxD <= 1;
            repeat (16) @(posedge sample_ENABLE);
        end
    endtask


    // TASK 3 – framing error (correct parity, wrong stop bit)
    task send_framing_error(input [7:0] value);
        begin
            RxD <= 0;
            repeat (16) @(posedge sample_ENABLE);

            for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) begin
                RxD <= value[bit_idx];
                repeat (16) @(posedge sample_ENABLE);
            end

            // Correct parity bit
            RxD <= ^value;
            repeat (16) @(posedge sample_ENABLE);

            // Wrong stop bit (0 instead of 1)
            RxD <= 0;
            repeat (16) @(posedge sample_ENABLE);
        end
    endtask


    // SIMULATION FLOW
    initial begin
        reset = 1;
        Rx_EN = 0;
        RxD = 1;
        baud_select = 3'b000;
        test_byte = 8'hA5;

        repeat(10) @(posedge clk);
        reset = 0;
        Rx_EN = 1;
        repeat(20) @(posedge sample_ENABLE);

        // 1. TEST OK BYTE
        send_ok_byte(test_byte);
        repeat(40) @(posedge sample_ENABLE);

        if (Rx_VALID && Rx_DATA == test_byte && !Rx_PERROR && !Rx_FERROR)
            $display("PASS: OK BYTE 0x%h", Rx_DATA);
        else
            $display("FAIL: OK BYTE");

        // 2. TEST PARITY ERROR
        send_parity_error(test_byte);
        repeat(40) @(posedge sample_ENABLE);

        if (Rx_PERROR && !Rx_VALID)
            $display("PASS: PARITY ERROR DETECTED");
        else
            $display("FAIL: PARITY ERROR NOT DETECTED");

        // 3. TEST FRAMING ERROR
        send_framing_error(test_byte);
        repeat(40) @(posedge sample_ENABLE);

        if (Rx_FERROR)
            $display("PASS: FRAMING ERROR DETECTED");
        else
            $display("FAIL: FRAMING ERROR NOT DETECTED");

        $finish;
    end

endmodule
