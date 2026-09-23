`timescale 1ns/1ps

module tb_instruction_decoder;

    reg  [15:0] instruction;

    wire [3:0] opcode;
    wire [2:0] rd;
    wire [2:0] rs1;
    wire [2:0] rs2;
    wire [7:0] immediate;
    wire [7:0] address;

    instruction_decoder dut (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .immediate(immediate),
        .address(address)
    );

    initial begin
        // TEST 1: LDI R0, 5 = C00A
        instruction = 16'hC00A;
        #1;

        if (opcode !== 4'b1100 ||
            rd !== 3'b000 ||
            immediate !== 8'd5)
            $display("FAIL: LDI R0, 5 decode");
        else
            $display("PASS: LDI R0, 5 decode");

        // TEST 2: LDI R1, 3 = C206
        instruction = 16'hC206;
        #1;

        if (opcode !== 4'b1100 ||
            rd !== 3'b001 ||
            immediate !== 8'd3)
            $display("FAIL: LDI R1, 3 decode");
        else
            $display("PASS: LDI R1, 3 decode");

        // TEST 3: ADD R2, R0, R1 = 1408
        instruction = 16'h1408;
        #1;

        if (opcode !== 4'b0001 ||
            rd !== 3'b010 ||
            rs1 !== 3'b000 ||
            rs2 !== 3'b001)
            $display("FAIL: ADD decode");
        else
            $display("PASS: ADD decode");

        // TEST 4: JMP 0x20
        // opcode = 1010
        // address = 00100000
        // reserved = 0000
        instruction = 16'b1010_00100000_0000;
        #1;

        if (opcode !== 4'b1010 ||
            address !== 8'h20)
            $display("FAIL: JMP decode");
        else
            $display("PASS: JMP decode");

        // TEST 5: CMP R1, R2
        // 1001 | 001 | 010 | 000000
        instruction = 16'b1001_001_010_000000;
        #1;

        if (opcode !== 4'b1001 ||
            rd !== 3'b001 ||
            rs1 !== 3'b010)
            $display("FAIL: CMP field decode");
        else
            $display("PASS: CMP field decode");

        $display("Instruction decoder tests complete.");
        $finish;
    end

endmodule