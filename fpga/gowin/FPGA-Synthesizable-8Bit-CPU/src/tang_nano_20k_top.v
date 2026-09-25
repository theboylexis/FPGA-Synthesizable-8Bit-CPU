module tang_nano_20k_top (
    input  wire       clk_27mhz,
    input  wire       reset_button,
    input  wire       select_button,
    output wire [5:0] led
);

    wire [7:0]  debug_register_data;
    wire        halted;
    wire [7:0]  pc_debug;
    wire [15:0] instruction_debug;

    reg [2:0] debug_register_address;

    always @(posedge clk_27mhz) begin
        if (reset_button)
            debug_register_address <= 3'b000;
        else if (select_button)
            debug_register_address <= debug_register_address + 3'b001;
    end

    cpu #(
        .PROGRAM_FILE("program.hex"),
        .PROGRAM_LENGTH(4)
    ) cpu_core (
        .clk(clk_27mhz),
        .reset(reset_button),

        .debug_register_address(debug_register_address),
        .debug_register_data(debug_register_data),

        .halted(halted),
        .pc_debug(pc_debug),
        .instruction_debug(instruction_debug)
    );

    assign led = ~debug_register_data[5:0];

endmodule