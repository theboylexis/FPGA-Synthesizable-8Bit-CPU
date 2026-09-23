`timescale 1ns/1ps

module tb_alu;

    reg  [7:0] operand_a;
    reg  [7:0] operand_b;
    reg  [2:0] alu_control;

    wire [7:0] result;
    wire       zero_flag;
    wire       carry_flag;
    wire       negative_flag;

    alu dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_control(alu_control),
        .result(result),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .negative_flag(negative_flag)
    );

    initial begin
        // ADD: 5 + 3 = 8
        operand_a = 8'd5;
        operand_b = 8'd3;
        alu_control = 3'b000;
        #1;

        if (result !== 8'd8 ||
            zero_flag !== 1'b0 ||
            negative_flag !== 1'b0 ||
            carry_flag !== 1'b0)
            $display("FAIL: ADD basic");
        else
            $display("PASS: ADD basic");

        // ADD with carry: 255 + 1 = 0, carry = 1
        operand_a = 8'd255;
        operand_b = 8'd1;
        alu_control = 3'b000;
        #1;

        if (result !== 8'd0 ||
            zero_flag !== 1'b1 ||
            negative_flag !== 1'b0 ||
            carry_flag !== 1'b1)
            $display("FAIL: ADD carry");
        else
            $display("PASS: ADD carry");

        // SUB: 10 - 6 = 4
        operand_a = 8'd10;
        operand_b = 8'd6;
        alu_control = 3'b001;
        #1;

        if (result !== 8'd4 ||
            zero_flag !== 1'b0 ||
            negative_flag !== 1'b0 ||
            carry_flag !== 1'b0)
            $display("FAIL: SUB basic");
        else
            $display("PASS: SUB basic");

        // SUB equal: 5 - 5 = 0
        operand_a = 8'd5;
        operand_b = 8'd5;
        alu_control = 3'b001;
        #1;

        if (result !== 8'd0 ||
            zero_flag !== 1'b1 ||
            negative_flag !== 1'b0 ||
            carry_flag !== 1'b0)
            $display("FAIL: SUB equal");
        else
            $display("PASS: SUB equal");

        // SUB with borrow: 3 - 5 = -2 = 8'hFE
        operand_a = 8'd3;
        operand_b = 8'd5;
        alu_control = 3'b001;
        #1;

        if (result !== 8'hFE ||
            zero_flag !== 1'b0 ||
            negative_flag !== 1'b1 ||
            carry_flag !== 1'b1)
            $display("FAIL: SUB borrow");
        else
            $display("PASS: SUB borrow");

        // AND
        operand_a = 8'b10101010;
        operand_b = 8'b11001100;
        alu_control = 3'b010;
        #1;

        if (result !== 8'b10001000 ||
            carry_flag !== 1'b0)
            $display("FAIL: AND");
        else
            $display("PASS: AND");

        // OR
        operand_a = 8'b10101010;
        operand_b = 8'b11001100;
        alu_control = 3'b011;
        #1;

        if (result !== 8'b11101110 ||
            carry_flag !== 1'b0)
            $display("FAIL: OR");
        else
            $display("PASS: OR");

        // XOR
        operand_a = 8'b10101010;
        operand_b = 8'b11001100;
        alu_control = 3'b100;
        #1;

        if (result !== 8'b01100110 ||
            carry_flag !== 1'b0)
            $display("FAIL: XOR");
        else
            $display("PASS: XOR");

        // Default / reserved control
        operand_a = 8'd12;
        operand_b = 8'd7;
        alu_control = 3'b111;
        #1;

        if (result !== 8'd0 ||
            zero_flag !== 1'b1 ||
            negative_flag !== 1'b0 ||
            carry_flag !== 1'b0)
            $display("FAIL: Default control");
        else
            $display("PASS: Default control");

        $display("ALU tests complete.");
        $finish;
    end

endmodule