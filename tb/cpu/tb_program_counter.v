`timescale 1ns/1ps

module tb_program_counter;

    reg        clk;
    reg        reset;
    reg        pc_write;
    reg        pc_increment;
    reg  [7:0] pc_target;

    wire [7:0] pc;

    program_counter dut (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .pc_increment(pc_increment),
        .pc_target(pc_target),
        .pc(pc)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset        = 1'b1;
        pc_write     = 1'b0;
        pc_increment = 1'b0;
        pc_target    = 8'b0;

        // TEST 1: Reset
        #10;
        reset = 1'b0;
        #1;

        if (pc !== 8'h00)
            $display("FAIL: Reset test");
        else
            $display("PASS: Reset test");

        // TEST 2: Increment
        pc_increment = 1'b1;

        #9;
        #1;

        pc_increment = 1'b0;

        if (pc !== 8'h01)
            $display("FAIL: Increment test");
        else
            $display("PASS: Increment test");

        // TEST 3: Load target address
        pc_write  = 1'b1;
        pc_target = 8'h80;

        #9;
        #1;

        pc_write = 1'b0;

        if (pc !== 8'h80)
            $display("FAIL: PC write test");
        else
            $display("PASS: PC write test");

        // TEST 4: pc_write has priority over increment
        pc_write     = 1'b1;
        pc_increment = 1'b1;
        pc_target    = 8'h25;

        #9;
        #1;

        pc_write     = 1'b0;
        pc_increment = 1'b0;

        if (pc !== 8'h25)
            $display("FAIL: Write priority test");
        else
            $display("PASS: Write priority test");

        // TEST 5: Hold
        #10;

        if (pc !== 8'h25)
            $display("FAIL: Hold test");
        else
            $display("PASS: Hold test");

        // TEST 6: Reset priority
        reset        = 1'b1;
        pc_write     = 1'b1;
        pc_increment = 1'b1;
        pc_target    = 8'hAA;

        #10;

        reset        = 1'b0;
        pc_write     = 1'b0;
        pc_increment = 1'b0;

        if (pc !== 8'h00)
            $display("FAIL: Reset priority test");
        else
            $display("PASS: Reset priority test");

        $display("Program counter tests complete.");
        $finish;
    end

endmodule