module led_blink (
    input  wire clk_27mhz,
    output wire led
);

    reg [23:0] counter = 24'd0;

    always @(posedge clk_27mhz) begin
        counter <= counter + 1'b1;
    end

    assign led = ~counter[23];

endmodule