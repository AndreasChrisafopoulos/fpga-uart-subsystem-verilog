// Debouncer module: synchronizes a noisy button signal, filters bouncing,
// and outputs a single clean pulse on rising edge.

module debouncer (
    input clk,          // Clock (100 MHz)
    input noisy_btn,    // Noisy signal from a physical button
    output reg btn_pulse // One-cycle output pulse on button press
);

    // Double synchronizer to avoid metastability
    reg btn_sync_0 ;
    reg btn_sync_1 ;
    
    // Clean, stable signal
    reg clean_btn = 0;

    // Stability counter
    reg [19:0] counter = 0; // 10 ms for 100 MHz

    // Signal synchronization with the clock
    always @(posedge clk) begin
        btn_sync_0 <= noisy_btn;
        btn_sync_1 <= btn_sync_0;
    end

    // Debouncing and pulse detection
    always @(posedge clk) begin
        btn_pulse <= 0; // default value — reset to zero every cycle

        if (btn_sync_1 == clean_btn)
            counter <= 0; // state did not change
        else begin
            counter <= counter + 1;
            if (counter == 20'hFFFFF) begin // stable for enough cycles
                clean_btn <= btn_sync_1; // update the clean value

                // If a 0->1 transition occurred, generate a 1-cycle pulse
                if (btn_sync_1 == 1'b1)
                    btn_pulse <= 1;
            end
        end
    end

endmodule
