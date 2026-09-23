`timescale 1ns/1ps

module tb_data_memory;

    reg        clk;
    reg        write_enable;
    reg  [7:0] address;
    reg  [7:0] write_data;

    wire [7:0] read_data;

    data_memory dut (
        .clk(clk),
        .write_enable(write_enable),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        write_enable = 1'b0;
        address      = 8'h00;
        write_data   = 8'h00;

        // TEST 1: Memory starts at zero
        #1;

        if (read_data !== 8'h00)
            $display("FAIL: Initial value test");
        else
            $display("PASS: Initial value test");

        // TEST 2: Write 42 to address 0x10
        address      = 8'h10;
        write_data   = 8'd42;
        write_enable = 1'b1;

        #4;  // Rising edge at 5 ns
        #1;

        write_enable = 1'b0;

        if (read_data !== 8'd42)
            $display("FAIL: Write/read test");
        else
            $display("PASS: Write/read test");

        // TEST 3: Write 99 to address 0x20
        address      = 8'h20;
        write_data   = 8'd99;
        write_enable = 1'b1;

        #9;  // Rising edge at 15 ns
        #1;

        write_enable = 1'b0;

        if (read_data !== 8'd99)
            $display("FAIL: Second write test");
        else
            $display("PASS: Second write test");

        // TEST 4: Verify first location still holds 42
        address = 8'h10;
        #1;

        if (read_data !== 8'd42)
            $display("FAIL: Data retention test");
        else
            $display("PASS: Data retention test");

        // TEST 5: write_enable = 0 prevents overwrite
        write_data   = 8'd200;
        write_enable = 1'b0;

        #9;  // Reach next rising edge
        #1;

        if (read_data !== 8'd42)
            $display("FAIL: Write-enable protection test");
        else
            $display("PASS: Write-enable protection test");

        $display("Data memory tests complete.");
        $finish;
    end

endmodule