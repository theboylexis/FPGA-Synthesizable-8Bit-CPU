`timescale 1ns/1ps

module tb_instruction_register;

    reg         clk;
    reg         reset;
    reg         load_enable;
    reg  [15:0] instruction_in;

    wire [15:0] instruction_out;

    instruction_register dut (
        .clk(clk),
        .reset(reset),
        .load_enable(load_enable),
        .instruction_in(instruction_in),
        .instruction_out(instruction_out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset          = 1'b1;
        load_enable    = 1'b0;
        instruction_in = 16'h0000;

        // TEST 1: Reset
        #10;
        reset = 1'b0;
        #1;

        if (instruction_out !== 16'h0000)
            $display("FAIL: Reset test");
        else
            $display("PASS: Reset test");

        // TEST 2: Load instruction
        instruction_in = 16'hC00A;
        load_enable    = 1'b1;

        #9;
        #1;

        load_enable = 1'b0;

        if (instruction_out !== 16'hC00A)
            $display("FAIL: Load test");
        else
            $display("PASS: Load test");

        // TEST 3: Hold previous instruction
        instruction_in = 16'h1408;
        load_enable    = 1'b0;

        #10;

        if (instruction_out !== 16'hC00A)
            $display("FAIL: Hold test");
        else
            $display("PASS: Hold test");

        // TEST 4: Load another instruction
        instruction_in = 16'h1408;
        load_enable    = 1'b1;

        #10;

        load_enable = 1'b0;

        if (instruction_out !== 16'h1408)
            $display("FAIL: Second load test");
        else
            $display("PASS: Second load test");

        // TEST 5: Reset priority over load
        reset          = 1'b1;
        load_enable    = 1'b1;
        instruction_in = 16'hFFFF;

        #10;

        reset       = 1'b0;
        load_enable = 1'b0;

        if (instruction_out !== 16'h0000)
            $display("FAIL: Reset priority test");
        else
            $display("PASS: Reset priority test");

        $display("Instruction register tests complete.");
        $finish;
    end

endmodule