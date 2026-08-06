// Testbench for baud_controller – verifies sample_ENABLE timing for all baud rates
`timescale 1ns/1ps

module tb_baud_controller();

    reg clk;
    reg reset;
    reg [2:0] baud_select;
    wire sample_ENABLE;

    // DUT
    baud_controller uut (
        .reset(reset),
        .clk(clk),
        .baud_select(baud_select),
        .sample_ENABLE(sample_ENABLE)
    );

    // Clock generation: 100 MHz => 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    integer i;
    initial begin
        
        // Start in reset
        reset = 1;
        baud_select = 3'b000;
        #50;
        reset = 0;

        // Loop through all 8 baud modes
        for (i = 0; i < 8; i = i + 1) begin
            
            baud_select = i[2:0];
            $display("TESTING BAUD MODE %0d at time %0t", i, $time);
            
            // Wait enough time to observe multiple pulses.
            case (baud_select)
                3'b000: #600000;   // 300 bps (slowest)
                3'b001: #200000;   // 1200
                3'b010: #60000;      // 4800
                3'b011: #30000;      // 9600
                3'b100: #15000;      // 19200
                3'b101: #8000;     // 38400
                3'b110: #4000;     // 57600
                3'b111: #2000;     // 115200
            endcase

            // Apply reset between modes
            reset = 1;
            #50;
            reset = 0;
        end
        
        $display("ALL TESTS COMPLETE");
        $finish;
    end

endmodule
