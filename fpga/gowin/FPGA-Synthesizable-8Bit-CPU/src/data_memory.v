module data_memory (
    input wire       clk,
    input wire       write_enable,
    input wire [7:0] address,
    input wire [7:0] write_data,

    output wire [7:0] read_data
);

    reg [7:0] memory [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 8'h00;
    end

    assign read_data = memory[address];

    always @(posedge clk) begin
        if (write_enable)
            memory[address] <= write_data;
    end

endmodule