module instruction_decoder (
    input  wire [15:0] instruction,

    output wire [3:0] opcode,
    output wire [2:0] rd,
    output wire [2:0] rs1,
    output wire [2:0] rs2,
    output wire [7:0] immediate,
    output wire [7:0] address
);

    assign opcode    = instruction[15:12];
    assign rd        = instruction[11:9];
    assign rs1       = instruction[8:6];
    assign rs2       = instruction[5:3];
    assign immediate = instruction[8:1];
    assign address   = instruction[11:4];

endmodule