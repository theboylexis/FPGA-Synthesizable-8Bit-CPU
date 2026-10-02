module button_test (
    input  wire       clk_27mhz,
    input  wire       s1,
    input  wire       s2,
    output wire [2:0] led
);

    reg [23:0] counter = 24'd0;

    always @(posedge clk_27mhz) begin
        counter <= counter + 1'b1;
    end

    // Direct button polarity test.
    //
    // Observed on the tested Tang Nano 20K setup:
    // released button = logic 0
    // pressed button  = logic 1
    //
    // Onboard LEDs are active-low:
    // logic 0 -> LED on
    // logic 1 -> LED off

    assign led[0] = s1;
    assign led[1] = s2;

    // Independent clock check using the 27 MHz onboard clock.
    assign led[2] = ~counter[23];

endmodule