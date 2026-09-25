module program_memory #(
    parameter PROGRAM_FILE   = "programs/tests/program.hex",
    parameter PROGRAM_LENGTH = 4
)(
    input  wire [7:0]  address,
    output wire [15:0] instruction
);

    reg [15:0] memory [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 16'h0000;

        $readmemh(
            PROGRAM_FILE,
            memory,
            0,
            PROGRAM_LENGTH - 1
        );
    end

    assign instruction = memory[address];

endmodule