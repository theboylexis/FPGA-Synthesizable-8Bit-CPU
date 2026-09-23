module program_counter (
    input wire       clk,
    input wire       reset,
    input wire       pc_write,
    input wire       pc_increment,
    input wire [7:0] pc_target,

    output reg  [7:0] pc
);

    always @(posedge clk) begin
        if (reset)
            pc <= 8'b0;
        else if (pc_write)
            pc <= pc_target;
        else if (pc_increment)
            pc <= pc + 8'd1;
    end

endmodule