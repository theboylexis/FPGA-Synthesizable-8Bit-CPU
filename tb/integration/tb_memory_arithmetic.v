`timescale 1ns/1ps

module tb_memory_arithmetic;

    reg clk;
    reg reset;

    wire       halted;
    wire [7:0] pc_debug;
    wire [15:0] instruction_debug;

    cpu #(
        .PROGRAM_FILE("programs/tests/memory_arithmetic.hex"),
        .PROGRAM_LENGTH(7)
    ) dut (
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

        #12;
        reset = 1'b0;

        #300;

        if (halted !== 1'b1)
            $display("FAIL: CPU did not halt");
        else
            $display("PASS: CPU halted");

        if (dut.registers.registers[0] !== 8'd10)
            $display("FAIL: R0 expected 10, got %0d",
                     dut.registers.registers[0]);
        else
            $display("PASS: R0 = 10");

        if (dut.registers.registers[1] !== 8'd6)
            $display("FAIL: R1 expected 6, got %0d",
                     dut.registers.registers[1]);
        else
            $display("PASS: R1 = 6");

        if (dut.registers.registers[2] !== 8'd4)
            $display("FAIL: R2 expected 4, got %0d",
                     dut.registers.registers[2]);
        else
            $display("PASS: R2 = 4");

        if (dut.registers.registers[3] !== 8'd4)
            $display("FAIL: R3 expected 4, got %0d",
                     dut.registers.registers[3]);
        else
            $display("PASS: R3 = 4");

        if (dut.registers.registers[4] !== 8'd4)
            $display("FAIL: R4 expected 4, got %0d",
                     dut.registers.registers[4]);
        else
            $display("PASS: R4 = 4");

        if (dut.data_mem.memory[8'h20] !== 8'd4)
            $display("FAIL: MEM[0x20] expected 4, got %0d",
                     dut.data_mem.memory[8'h20]);
        else
            $display("PASS: MEM[0x20] = 4");

        $display("Memory/arithmetic integration test complete.");
        $finish;
    end

endmodule