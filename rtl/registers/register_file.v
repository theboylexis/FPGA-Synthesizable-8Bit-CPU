module register_file (
    input wire [2:0] read_address_1,
    input wire [2:0] read_address_2,
    input wire [2:0] write_address,
    input wire [7:0] write_data,
    input wire write_enable,
    input wire clk,
    input wire reset,

    output wire [7:0] read_data_1,
    output wire [7:0] read_data_2

);
    reg [7:0] registers [0:7];
    assign read_data_1 = registers[read_address_1];
    assign read_data_2 = registers[read_address_2];

    integer i;

always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 8; i = i + 1) begin
            registers[i] <= 8'b0;
        end
    end
    else if (write_enable) begin
        registers[write_address] <= write_data;
    end
end

endmodule