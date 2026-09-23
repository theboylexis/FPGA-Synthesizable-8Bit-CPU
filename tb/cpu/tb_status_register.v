`timescale 1ns/1ps

module tb_status_register;

    reg clk;
    reg reset;
    reg write_enable;

    reg zero_in;
    reg negative_in;
    reg carry_in;

    wire zero_out;
    wire negative_out;
    wire carry_out;

    status_register dut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),

        .zero_in(zero_in),
        .negative_in(negative_in),
        .carry_in(carry_in),

        .zero_out(zero_out),
        .negative_out(negative_out),
        .carry_out(carry_out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset        = 1'b1;
        write_enable = 1'b0;

        zero_in      = 1'b0;
        negative_in  = 1'b0;
        carry_in     = 1'b0;

        // TEST 1: Reset clears flags
        #10;
        reset = 1'b0;
        #1;

        if (zero_out !== 1'b0 ||
            negative_out !== 1'b0 ||
            carry_out !== 1'b0)
            $display("FAIL: Reset test");
        else
            $display("PASS: Reset test");

        // TEST 2: Capture flags
        zero_in      = 1'b1;
        negative_in  = 1'b0;
        carry_in     = 1'b1;
        write_enable = 1'b1;

        #9;
        #1;

        write_enable = 1'b0;

        if (zero_out !== 1'b1 ||
            negative_out !== 1'b0 ||
            carry_out !== 1'b1)
            $display("FAIL: Flag write test");
        else
            $display("PASS: Flag write test");

        // TEST 3: Hold previous flags
        zero_in     = 1'b0;
        negative_in = 1'b1;
        carry_in    = 1'b0;

        #10;

        if (zero_out !== 1'b1 ||
            negative_out !== 1'b0 ||
            carry_out !== 1'b1)
            $display("FAIL: Hold test");
        else
            $display("PASS: Hold test");

        // TEST 4: Write new flags
        write_enable = 1'b1;

        #10;

        write_enable = 1'b0;

        if (zero_out !== 1'b0 ||
            negative_out !== 1'b1 ||
            carry_out !== 1'b0)
            $display("FAIL: Second flag write test");
        else
            $display("PASS: Second flag write test");

        // TEST 5: Reset priority
        reset        = 1'b1;
        write_enable = 1'b1;

        zero_in     = 1'b1;
        negative_in = 1'b1;
        carry_in    = 1'b1;

        #10;

        reset        = 1'b0;
        write_enable = 1'b0;

        if (zero_out !== 1'b0 ||
            negative_out !== 1'b0 ||
            carry_out !== 1'b0)
            $display("FAIL: Reset priority test");
        else
            $display("PASS: Reset priority test");

        $display("Status register tests complete.");
        $finish;
    end

endmodule