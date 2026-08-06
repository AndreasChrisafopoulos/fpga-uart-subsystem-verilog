// Baud rate controller – generates sample_ENABLE pulses based on selected baud rate

module baud_controller(
    input reset,
    input clk,                    // 100 MHz clock
    input [2:0] baud_select,
    output reg sample_ENABLE
);

    reg [15:0] counter;
    reg [15:0] max_count;

    always @(baud_select) 
    begin
        case (baud_select)
            3'b000: max_count = 20833;   // 300 bps
            3'b001: max_count = 5208;    // 1200 bps
            3'b010: max_count = 1302;    // 4800 bps
            3'b011: max_count = 651;     // 9600 bps
            3'b100: max_count = 326;     // 19200 bps
            3'b101: max_count = 163;     // 38400 bps
            3'b110: max_count = 109;     // 57600 bps
            3'b111: max_count = 54;      // 115200 bps
            default:max_count = 54;
        endcase
    end

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            counter            <= 0;
            sample_ENABLE      <= 0;
        end 
        else 
        begin
            if (counter == max_count) 
            begin
                counter        <= 0;
                sample_ENABLE  <= 1;
            end 
            else 
            begin
                counter        <= counter + 1;
                sample_ENABLE  <= 0;
            end
        end
    end

endmodule
