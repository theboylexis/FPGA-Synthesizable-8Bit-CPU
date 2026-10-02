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

    // ---------------------------------------------------------
    // S1 button synchronization and debounce
    // ---------------------------------------------------------

    reg select_sync_0;
    reg select_sync_1;

    reg select_debounced;
    reg select_debounced_d;

    reg [17:0] debounce_counter;

    always @(posedge clk_27mhz) begin
        if (reset_button) begin
            select_sync_0      <= 1'b0;
            select_sync_1      <= 1'b0;
            select_debounced   <= 1'b0;
            select_debounced_d <= 1'b0;
            debounce_counter   <= 18'd0;
        end
        else begin

            // Synchronize the asynchronous pushbutton input
            select_sync_0 <= select_button;
            select_sync_1 <= select_sync_0;

            // Debounce S1
            if (select_sync_1 == select_debounced) begin
                debounce_counter <= 18'd0;
            end
            else begin
                if (debounce_counter == 18'd134999) begin
                    select_debounced <= select_sync_1;
                    debounce_counter <= 18'd0;
                end
                else begin
                    debounce_counter <= debounce_counter + 1'b1;
                end
            end

            // Store previous debounced state
            select_debounced_d <= select_debounced;
        end
    end


    // One-clock pulse when S1 is cleanly pressed
    wire select_press_pulse;

    assign select_press_pulse =
        select_debounced & ~select_debounced_d;


    // ---------------------------------------------------------
    // Debug register selector
    // ---------------------------------------------------------

    always @(posedge clk_27mhz) begin
        if (reset_button)
            debug_register_address <= 3'b000;

        else if (select_press_pulse)
            debug_register_address <=
                debug_register_address + 3'b001;
    end


    // ---------------------------------------------------------
    // CPU
    // ---------------------------------------------------------

    cpu #(
        .PROGRAM_FILE("program.hex"),
        .PROGRAM_LENGTH(15)
    ) cpu_core (
        .clk(clk_27mhz),
        .reset(reset_button),

        .debug_register_address(debug_register_address),
        .debug_register_data(debug_register_data),

        .halted(halted),
        .pc_debug(pc_debug),
        .instruction_debug(instruction_debug)
    );


    // ---------------------------------------------------------
    // LED debug output
    // Tang Nano 20K LEDs are active-low
    // ---------------------------------------------------------

    assign led = ~debug_register_data[5:0];

endmodule