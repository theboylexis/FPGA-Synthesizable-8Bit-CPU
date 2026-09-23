`timescale 1ns/1ps

module tb_cpu;

    reg clk;
    reg reset;

    wire       halted;
    wire [7:0] pc_debug;
    wire [15:0] instruction_debug;

    cpu dut (
        .clk(clk),
        .reset(reset),
        .halted(halted),
        .pc_debug(pc_debug),
        .instruction_debug(instruction_debug)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1'b1;

        // Hold reset for two clock edges
        #12;
        reset = 1'b0;

        // Allow enough time for the 4-instruction program to complete
        #200;

        if (halted !== 1'b1)
            $display("FAIL: CPU did not halt");
        else
            $display("PASS: CPU halted");

        // Access internal register-file storage for integration verification
        if (dut.registers.registers[0] !== 8'd5)
            $display("FAIL: R0 expected 5, got %0d",
                     dut.registers.registers[0]);
        else
            $display("PASS: R0 = 5");

        if (dut.registers.registers[1] !== 8'd3)
            $display("FAIL: R1 expected 3, got %0d",
                     dut.registers.registers[1]);
        else
            $display("PASS: R1 = 3");

        if (dut.registers.registers[2] !== 8'd8)
            $display("FAIL: R2 expected 8, got %0d",
                     dut.registers.registers[2]);
        else
            $display("PASS: R2 = 8");

        $display("Final PC = %0d", pc_debug);
        $display("Final instruction = %h", instruction_debug);

        $display("CPU integration test complete.");
        $finish;
    end

endmodule