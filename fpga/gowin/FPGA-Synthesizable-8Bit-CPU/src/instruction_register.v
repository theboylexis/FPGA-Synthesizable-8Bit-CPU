module instruction_register (
    input wire        clk,
    input wire        reset,
    input wire        load_enable,
    input wire [15:0] instruction_in,

    output reg  [15:0] instruction_out
);

    always @(posedge clk) begin
        if (reset)
            instruction_out <= 16'h0000;
        else if (load_enable)
            instruction_out <= instruction_in;
    end

endmodule