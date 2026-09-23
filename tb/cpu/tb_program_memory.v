`timescale 1ns/1ps

module tb_program_memory;

    reg  [7:0]  address;
    wire [15:0] instruction;

    program_memory dut (
        .address(address),
        .instruction(instruction)
    );

    initial begin
        // Address 0 -> LDI R0, 5
        address = 8'h00;
        #1;

        if (instruction !== 16'hC00A)
            $display("FAIL: Address 0");
        else
            $display("PASS: Address 0");

        // Address 1 -> LDI R1, 3
        address = 8'h01;
        #1;

        if (instruction !== 16'hC206)
            $display("FAIL: Address 1");
        else
            $display("PASS: Address 1");

        // Address 2 -> ADD R2, R0, R1
        address = 8'h02;
        #1;

        if (instruction !== 16'h1408)
            $display("FAIL: Address 2");
        else
            $display("PASS: Address 2");

        // Address 3 -> HALT
        address = 8'h03;
        #1;

        if (instruction !== 16'h0000)
            $display("FAIL: Address 3");
        else
            $display("PASS: Address 3");

        $display("Program memory tests complete.");
        $finish;
    end

endmodule