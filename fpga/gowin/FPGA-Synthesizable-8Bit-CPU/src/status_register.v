module status_register (
    input wire clk,
    input wire reset,
    input wire write_enable,

    input wire zero_in,
    input wire negative_in,
    input wire carry_in,

    output reg zero_out,
    output reg negative_out,
    output reg carry_out
);

    always @(posedge clk) begin
        if (reset) begin
            zero_out     <= 1'b0;
            negative_out <= 1'b0;
            carry_out    <= 1'b0;
        end
        else if (write_enable) begin
            zero_out     <= zero_in;
            negative_out <= negative_in;
            carry_out    <= carry_in;
        end
    end

endmodule