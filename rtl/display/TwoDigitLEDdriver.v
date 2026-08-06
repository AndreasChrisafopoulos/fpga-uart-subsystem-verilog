// Two-digit 7-segment LED driver: displays an 8-bit value using multiplexed anodes 
// and MMCM-generated 5 MHz clock.

`timescale 1ns / 1ps

module TwoDigitLEDdriver(
    input clk,          // 100 MHz system clock
    input reset,
    input [7:0] data,   // input byte
    input valid,        // load enable

    output reg an3, an2, an1, an0, // common anodes
    output a, b, c, d, e, f, g, dp // 7-segment outputs
);


// MMCM: generate 5 MHz display clock
wire mmcm_clk;
wire mmcm_fb;
wire mmcm_locked;

MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKFBOUT_MULT_F(6.0),        // 100 MHz * 6 = 600 MHz VCO
    .CLKIN1_PERIOD(10.0),
    .CLKOUT0_DIVIDE_F(120.0),     // 600 / 120 = 5 MHz
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0.0),
    .DIVCLK_DIVIDE(1),
    .STARTUP_WAIT("FALSE")
)
MMCME2_BASE_inst (
    .CLKIN1(clk),
    .CLKFBIN(mmcm_fb),
    .CLKFBOUT(mmcm_fb),
    .CLKOUT0(mmcm_clk),
    .LOCKED(mmcm_locked),
    .PWRDWN(1'b0),
    .RST(reset)
);


// Register input byte when valid=1
reg [7:0] data_reg;

always @(posedge clk or posedge reset) begin
    if (reset)
        data_reg <= 8'h00;
    else if (valid)
        data_reg <= data;
end


// Split into digits
wire [3:0] digit_low  = data_reg[3:0];
wire [3:0] digit_high = data_reg[7:4];


// Digit select counter (multiplexing)
reg [3:0] an_counter;

always @(posedge mmcm_clk or posedge reset) begin
    if (reset)
        an_counter <= 4'b1111;
    else
        an_counter <= an_counter - 1;
end


// Enable only AN1 or AN0
always @(an_counter) begin
    case(an_counter)
        4'b1110: {an3, an2, an1, an0} = 4'b0111; // AN3 on
        4'b1010: {an3, an2, an1, an0} = 4'b1011; // AN2 on
        4'b0110: {an3, an2, an1, an0} = 4'b1101; // AN1 on
        4'b0010: {an3, an2, an1, an0} = 4'b1110; // AN0 on
        default: {an3, an2, an1, an0} = 4'b1111; // all off
    endcase
end


// Digit selection for segment driver
reg [3:0] digit0 = 4'h0;
reg [3:0] current_digit;

always @(an_counter) begin
    case(an_counter)
        4'b0000: current_digit = digit0;
        4'b1111: current_digit = digit0;
        4'b1110: current_digit = digit0;
        4'b1101: current_digit = digit0;
        4'b1100: current_digit = digit0;
        4'b1011: current_digit = digit0;
        4'b1010: current_digit = digit0;
        4'b1001: current_digit = digit0;
        4'b1000: current_digit = digit_high;
        4'b0111: current_digit = digit_high;
        4'b0110: current_digit = digit_high;
        4'b0101: current_digit = digit_high;
        4'b0100: current_digit = digit_low;
        4'b0011: current_digit = digit_low;
        4'b0010: current_digit = digit_low;
        4'b0001: current_digit = digit_low;
        default: current_digit = digit0;
    endcase
end


// 7-seg decoder
LEDdecoder LEDdecoder_inst(
    .char(current_digit),
    .CA(a),
    .CB(b),
    .CC(c),
    .CD(d),
    .CE(e),
    .CF(f),
    .CG(g)
);

assign dp = 1'b1; // decimal point always off

endmodule
