`timescale 1ns/1ps

module tb_register_file;

    reg        clk;
    reg        reset;
    reg        write_enable;
    reg  [2:0] read_address_1;
    reg  [2:0] read_address_2;
    reg  [2:0] write_address;
    reg  [7:0] write_data;

    wire [7:0] read_data_1;
    wire [7:0] read_data_2;

    register_file dut (
        .read_address_1(read_address_1),
        .read_address_2(read_address_2),
        .write_address(write_address),
        .write_data(write_data),
        .write_enable(write_enable),
        .clk(clk),
        .reset(reset),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

        initial begin
        // Initial values
        reset          = 1'b1;
        write_enable   = 1'b0;
        read_address_1 = 3'b000;
        read_address_2 = 3'b000;
        write_address  = 3'b000;
        write_data     = 8'b00000000;

        // -------------------------------------------------
        // TEST 1: Reset should clear all registers
        // -------------------------------------------------
        #10;
        reset = 1'b0;

        read_address_1 = 3'b000; // R0
        read_address_2 = 3'b111; // R7
        #1;

        if (read_data_1 !== 8'h00 || read_data_2 !== 8'h00)
            $display("FAIL: Reset test");
        else
            $display("PASS: Reset test");

        // -------------------------------------------------
        // TEST 2: Write 42 to R2
        // -------------------------------------------------
        write_enable  = 1'b1;
        write_address = 3'b010;  // R2
        write_data    = 8'd42;

        #9;  // Reach next rising edge at 20 ns
        #1;  // Allow non-blocking assignment to update

        write_enable   = 1'b0;
        read_address_1 = 3'b010;
        #1;

        if (read_data_1 !== 8'd42)
            $display("FAIL: R2 write/read test");
        else
            $display("PASS: R2 write/read test");

        // -------------------------------------------------
        // TEST 3: Write 99 to R5
        // -------------------------------------------------
        write_enable  = 1'b1;
        write_address = 3'b101;  // R5
        write_data    = 8'd99;

        #8;  // Reach next rising edge at 30 ns
        #1;

        write_enable   = 1'b0;

        // Read R2 and R5 simultaneously
        read_address_1 = 3'b010;
        read_address_2 = 3'b101;
        #1;

        if (read_data_1 !== 8'd42 || read_data_2 !== 8'd99)
            $display("FAIL: Dual read test");
        else
            $display("PASS: Dual read test");

        // -------------------------------------------------
        // TEST 4: write_enable = 0 should prevent writes
        // -------------------------------------------------
        write_enable  = 1'b0;
        write_address = 3'b010;  // Attempt to overwrite R2
        write_data    = 8'd200;

        #9;  // Reach next rising edge at 40 ns
        #1;

        read_address_1 = 3'b010;
        #1;

        if (read_data_1 !== 8'd42)
            $display("FAIL: Write-enable protection test");
        else
            $display("PASS: Write-enable protection test");

        // -------------------------------------------------
        // TEST 5: Reset must have priority over write
        // -------------------------------------------------
        reset         = 1'b1;
        write_enable  = 1'b1;
        write_address = 3'b101;
        write_data    = 8'd123;

        #8;  // Reach next rising edge at 50 ns
        #1;

        reset        = 1'b0;
        write_enable = 1'b0;

        read_address_1 = 3'b010; // R2
        read_address_2 = 3'b101; // R5
        #1;

        if (read_data_1 !== 8'h00 || read_data_2 !== 8'h00)
            $display("FAIL: Reset priority test");
        else
            $display("PASS: Reset priority test");

        // -------------------------------------------------
        // End simulation
        // -------------------------------------------------
        $display("Register file tests complete.");
        $finish;
    end

endmodule