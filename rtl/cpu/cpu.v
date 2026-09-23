module cpu #(
    parameter PROGRAM_FILE   = "programs/tests/program.hex",
    parameter PROGRAM_LENGTH = 4
)(
    input wire clk,
    input wire reset,

    output wire        halted,
    output wire [7:0]  pc_debug,
    output wire [15:0] instruction_debug
);

    // -------------------------------------------------
    // Program Counter
    // -------------------------------------------------
    wire [7:0] pc;
    wire       pc_write;
    wire       pc_increment;
    wire [7:0] pc_target;

    // -------------------------------------------------
    // Program Memory
    // -------------------------------------------------
    wire [15:0] program_instruction;

    // -------------------------------------------------
    // Instruction Register
    // -------------------------------------------------
    wire        instruction_load;
    wire [15:0] current_instruction;

    assign pc_debug          = pc;
    assign instruction_debug = current_instruction;

    program_counter pc_unit (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .pc_increment(pc_increment),
        .pc_target(pc_target),
        .pc(pc)
    );

    program_memory #(
        .PROGRAM_FILE(PROGRAM_FILE),
        .PROGRAM_LENGTH(PROGRAM_LENGTH)
    ) program_mem (
        .address(pc),
        .instruction(program_instruction)
    );

    instruction_register instruction_reg (
        .clk(clk),
        .reset(reset),
        .load_enable(instruction_load),
        .instruction_in(program_instruction),
        .instruction_out(current_instruction)
    );

    // -------------------------------------------------
    // Instruction Decoder
    // -------------------------------------------------
    wire [3:0] opcode;
    wire [2:0] rd;
    wire [2:0] rs1;
    wire [2:0] rs2;
    wire [7:0] immediate;
    wire [7:0] address;

    instruction_decoder decoder (
        .instruction(current_instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .immediate(immediate),
        .address(address)
    );

    // -------------------------------------------------
    // Control Unit
    // -------------------------------------------------
    wire       register_write_enable;
    wire       memory_write_enable;
    wire       flag_write_enable;
    wire [2:0] alu_control;
    wire [1:0] writeback_select;

    wire stored_zero_flag;

    control_unit control (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .zero_flag(stored_zero_flag),

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

    assign pc_target = address;

    // -------------------------------------------------
    // Register File
    // -------------------------------------------------
    wire [2:0] read_address_1;
    wire [2:0] read_address_2;

    wire [7:0] register_data_1;
    wire [7:0] register_data_2;
    wire [7:0] register_write_data;

    assign read_address_1 =
        (opcode == 4'b1001) ? rd  :
        (opcode == 4'b1000) ? rd  :
                              rs1;

    assign read_address_2 =
        (opcode == 4'b1001) ? rs1 :
                              rs2;

    register_file registers (
        .read_address_1(read_address_1),
        .read_address_2(read_address_2),
        .write_address(rd),
        .write_data(register_write_data),
        .write_enable(register_write_enable),
        .clk(clk),
        .reset(reset),

        .read_data_1(register_data_1),
        .read_data_2(register_data_2)
    );

    // -------------------------------------------------
    // ALU
    // -------------------------------------------------
    wire [7:0] alu_result;
    wire       alu_zero_flag;
    wire       alu_carry_flag;
    wire       alu_negative_flag;

    alu alu_unit (
        .operand_a(register_data_1),
        .operand_b(register_data_2),
        .alu_control(alu_control),

        .result(alu_result),
        .zero_flag(alu_zero_flag),
        .carry_flag(alu_carry_flag),
        .negative_flag(alu_negative_flag)
    );

    // -------------------------------------------------
    // Status Register
    // -------------------------------------------------
    wire stored_negative_flag;
    wire stored_carry_flag;

    status_register status (
        .clk(clk),
        .reset(reset),
        .write_enable(flag_write_enable),

        .zero_in(alu_zero_flag),
        .negative_in(alu_negative_flag),
        .carry_in(alu_carry_flag),

        .zero_out(stored_zero_flag),
        .negative_out(stored_negative_flag),
        .carry_out(stored_carry_flag)
    );

    // -------------------------------------------------
    // Data Memory
    // -------------------------------------------------
    wire [7:0] memory_read_data;

    data_memory data_mem (
        .clk(clk),
        .write_enable(memory_write_enable),
        .address(immediate),
        .write_data(register_data_1),
        .read_data(memory_read_data)
    );

    // -------------------------------------------------
    // Register Writeback Multiplexer
    // -------------------------------------------------
    reg [7:0] writeback_data;

    always @(*) begin
        case (writeback_select)

            2'b00: begin
                writeback_data = alu_result;
            end

            2'b01: begin
                writeback_data = memory_read_data;
            end

            2'b10: begin
                writeback_data = immediate;
            end

            2'b11: begin
                writeback_data = register_data_1;
            end

            default: begin
                writeback_data = 8'h00;
            end

        endcase
    end

    assign register_write_data = writeback_data;

endmodule