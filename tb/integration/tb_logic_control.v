`timescale 1ns/1ps

module tb_logic_control;

    reg clk;
    reg reset;

    wire        halted;
    wire [7:0]  pc_debug;
    wire [15:0] instruction_debug;

    cpu #(
        .PROGRAM_FILE("programs/tests/logic_control.hex"),
        .PROGRAM_LENGTH(15)
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

        #500;

        if (halted !== 1'b1)
            $display("FAIL: CPU did not halt");
        else
            $display("PASS: CPU halted");

        if (dut.registers.registers[0] !== 8'h0F)
            $display("FAIL: R0 expected 0x0F, got 0x%h",
                     dut.registers.registers[0]);
        else
            $display("PASS: R0 = 0x0F");

        if (dut.registers.registers[1] !== 8'h33)
            $display("FAIL: R1 expected 0x33, got 0x%h",
                     dut.registers.registers[1]);
        else
            $display("PASS: R1 = 0x33");

        if (dut.registers.registers[2] !== 8'h03)
            $display("FAIL: AND result incorrect, R2 = 0x%h",
                     dut.registers.registers[2]);
        else
            $display("PASS: AND result R2 = 0x03");

        if (dut.registers.registers[3] !== 8'h3F)
            $display("FAIL: OR result incorrect, R3 = 0x%h",
                     dut.registers.registers[3]);
        else
            $display("PASS: OR result R3 = 0x3F");

        if (dut.registers.registers[4] !== 8'h3C)
            $display("FAIL: XOR result incorrect, R4 = 0x%h",
                     dut.registers.registers[4]);
        else
            $display("PASS: XOR result R4 = 0x3C");

        // R5 proves both branch cases:
        // 0xAA must be skipped by taken BEQ,
        // 0x55 must execute after not-taken BEQ.
        if (dut.registers.registers[5] !== 8'h55)
            $display("FAIL: BEQ behavior incorrect, R5 = 0x%h",
                     dut.registers.registers[5]);
        else
            $display("PASS: BEQ taken/not-taken behavior");

        // R6 proves JMP skipped address 12.
        if (dut.registers.registers[6] !== 8'h11)
            $display("FAIL: JMP behavior incorrect, R6 = 0x%h",
                     dut.registers.registers[6]);
        else
            $display("PASS: JMP behavior");

        $display("Logic/control integration test complete.");
        $finish;
    end

endmodule