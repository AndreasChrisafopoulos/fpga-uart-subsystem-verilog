// Two-stage input synchronizer for the asynchronous RxD signal, used to prevent
// metastability and align the signal to the system clock domain.
module synchronizer(
    input  clk,
    input  reset,
    input  RxD,
    output reg RxD_sync
);

    reg ff1;

    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            ff1      <= 1'b1;
            RxD_sync <= 1'b1;
        end 
        else 
        begin
            ff1      <= RxD;
            RxD_sync <= ff1;
        end
    end

endmodule
