`timescale 1ns/1ps

module tb_control_unit;

    reg        clk;
    reg        reset;
    reg [3:0]  opcode;
    reg        zero_flag;

    wire       instruction_load;
    wire       pc_increment;
    wire       pc_write;
    wire       register_write_enable;
    wire       memory_write_enable;
    wire       flag_write_enable;
    wire [2:0] alu_control;
    wire [1:0] writeback_select;
    wire       halted;

    control_unit dut (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .zero_flag(zero_flag),

        .instruction_load(instruction_load),
        .pc_increment(pc_increment),
        .pc_write(pc_write),
        .register_write_enable(register_write_enable),
        .memory_write_enable(memory_write_enable),
        .flag_write_enable(flag_write_enable),
        .alu_control(alu_control),
        .writeback_select(writeback_select),
        .halted(halted)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset     = 1'b1;
        opcode    = 4'b0000;
        zero_flag = 1'b0;

        // Reset -> FETCH
        #10;
        reset = 1'b0;
        #1;

        if (instruction_load !== 1'b1 ||
            pc_increment !== 1'b1)
            $display("FAIL: FETCH state");
        else
            $display("PASS: FETCH state");

        // ADD path
        opcode = 4'b0001;

        #9;  // DECODE
        #10; // EXECUTE
        #1;

        if (alu_control !== 3'b000 ||
            flag_write_enable !== 1'b1)
            $display("FAIL: ADD execute");
        else
            $display("PASS: ADD execute");

        #9;  // WRITEBACK
        #1;

        if (register_write_enable !== 1'b1 ||
            writeback_select !== 2'b00)
            $display("FAIL: ADD writeback");
        else
            $display("PASS: ADD writeback");

        // Return to FETCH
        #9;
        #1;

        // LDI path
        opcode = 4'b1100;

        #9;  // DECODE
        #10; // WRITEBACK
        #1;

        if (register_write_enable !== 1'b1 ||
            writeback_select !== 2'b10)
            $display("FAIL: LDI writeback");
        else
            $display("PASS: LDI writeback");

        // Return to FETCH
        #9;
        #1;

        // STORE path
        opcode = 4'b1000;

        #9;  // DECODE
        #10; // MEMORY
        #1;

        if (memory_write_enable !== 1'b1)
            $display("FAIL: STORE memory write");
        else
            $display("PASS: STORE memory write");

        // Return to FETCH
        #9;
        #1;

        // JMP path
        opcode = 4'b1010;

        #9;  // DECODE
        #10; // EXECUTE
        #1;

        if (pc_write !== 1'b1)
            $display("FAIL: JMP");
        else
            $display("PASS: JMP");

        // Return to FETCH
        #9;
        #1;

        // BEQ not taken
        opcode    = 4'b1011;
        zero_flag = 1'b0;

        #9;  // DECODE
        #10; // EXECUTE
        #1;

        if (pc_write !== 1'b0)
            $display("FAIL: BEQ not taken");
        else
            $display("PASS: BEQ not taken");

        // Return to FETCH
        #9;
        #1;

        // BEQ taken
        opcode    = 4'b1011;
        zero_flag = 1'b1;

        #9;  // DECODE
        #10; // EXECUTE
        #1;

        if (pc_write !== 1'b1)
            $display("FAIL: BEQ taken");
        else
            $display("PASS: BEQ taken");

        // Return to FETCH
        #9;
        #1;

        // HALT path
        opcode = 4'b0000;

        #9;  // DECODE
        #10; // HALT
        #1;

        if (halted !== 1'b1)
            $display("FAIL: HALT");
        else
            $display("PASS: HALT");

        $display("Control unit tests complete.");
        $finish;
    end

endmodule