```verilog
module control_unit (
    input wire       clk,
    input wire       reset,
    input wire [3:0] opcode,
    input wire       zero_flag,

    output reg       instruction_load,
    output reg       pc_increment,
    output reg       pc_write,
    output reg       register_write_enable,
    output reg       memory_write_enable,
    output reg       flag_write_enable,
    output reg [2:0] alu_control,
    output reg [1:0] writeback_select,
    output reg       halted
);

    // FSM states
    localparam STATE_FETCH     = 3'b000;
    localparam STATE_DECODE    = 3'b001;
    localparam STATE_EXECUTE   = 3'b010;
    localparam STATE_MEMORY    = 3'b011;
    localparam STATE_WRITEBACK = 3'b100;
    localparam STATE_HALT      = 3'b101;

    // Writeback sources
    localparam WB_ALU       = 2'b00;
    localparam WB_MEMORY    = 2'b01;
    localparam WB_IMMEDIATE = 2'b10;
    localparam WB_REGISTER  = 2'b11;

    reg [2:0] current_state;
    reg [2:0] next_state;

    // State register
    always @(posedge clk) begin
        if (reset)
            current_state <= STATE_FETCH;
        else
            current_state <= next_state;
    end

    // Control and next-state logic
    always @(*) begin

        // Default outputs
        instruction_load      = 1'b0;
        pc_increment          = 1'b0;
        pc_write              = 1'b0;
        register_write_enable = 1'b0;
        memory_write_enable   = 1'b0;
        flag_write_enable     = 1'b0;
        alu_control           = 3'b000;
        writeback_select      = WB_ALU;
        halted                = 1'b0;

        // Default state behavior
        next_state = current_state;

        case (current_state)

            // -------------------------------------------------
            // FETCH
            // -------------------------------------------------
            STATE_FETCH: begin
                instruction_load = 1'b1;
                pc_increment     = 1'b1;
                next_state       = STATE_DECODE;
            end

            // -------------------------------------------------
            // DECODE
            // -------------------------------------------------
            STATE_DECODE: begin
                case (opcode)

                    4'b0000: begin // HALT
                        next_state = STATE_HALT;
                    end

                    4'b0001, // ADD
                    4'b0010, // SUB
                    4'b0011, // AND
                    4'b0100, // OR
                    4'b0101, // XOR
                    4'b1001, // CMP
                    4'b1010, // JMP
                    4'b1011: begin // BEQ
                        next_state = STATE_EXECUTE;
                    end

                    4'b0110, // MOV
                    4'b1100: begin // LDI
                        next_state = STATE_WRITEBACK;
                    end

                    4'b0111, // LOAD
                    4'b1000: begin // STORE
                        next_state = STATE_MEMORY;
                    end

                    default: begin
                        next_state = STATE_HALT;
                    end

                endcase
            end

            // -------------------------------------------------
            // EXECUTE
            // -------------------------------------------------
            STATE_EXECUTE: begin
                case (opcode)

                    4'b0001: begin // ADD
                        alu_control        = 3'b000;
                        flag_write_enable = 1'b1;
                        next_state         = STATE_WRITEBACK;
                    end

                    4'b0010: begin // SUB
                        alu_control        = 3'b001;
                        flag_write_enable = 1'b1;
                        next_state         = STATE_WRITEBACK;
                    end

                    4'b0011: begin // AND
                        alu_control = 3'b010;
                        next_state  = STATE_WRITEBACK;
                    end

                    4'b0100: begin // OR
                        alu_control = 3'b011;
                        next_state  = STATE_WRITEBACK;
                    end

                    4'b0101: begin // XOR
                        alu_control = 3'b100;
                        next_state  = STATE_WRITEBACK;
                    end

                    4'b1001: begin // CMP
                        alu_control        = 3'b001;
                        flag_write_enable = 1'b1;
                        next_state         = STATE_FETCH;
                    end

                    4'b1010: begin // JMP
                        pc_write   = 1'b1;
                        next_state = STATE_FETCH;
                    end

                    4'b1011: begin // BEQ
                        if (zero_flag)
                            pc_write = 1'b1;

                        next_state = STATE_FETCH;
                    end

                    default: begin
                        next_state = STATE_HALT;
                    end

                endcase
            end

            // -------------------------------------------------
            // MEMORY
            // -------------------------------------------------
            STATE_MEMORY: begin
                case (opcode)

                    4'b0111: begin // LOAD
                        next_state = STATE_WRITEBACK;
                    end

                    4'b1000: begin // STORE
                        memory_write_enable = 1'b1;
                        next_state          = STATE_FETCH;
                    end

                    default: begin
                        next_state = STATE_HALT;
                    end

                endcase
            end

            // -------------------------------------------------
            // WRITEBACK
            // -------------------------------------------------
            STATE_WRITEBACK: begin
                case (opcode)

                    4'b0001: begin // ADD
                        alu_control           = 3'b000;
                        register_write_enable = 1'b1;
                        writeback_select      = WB_ALU;
                        next_state            = STATE_FETCH;
                    end

                    4'b0010: begin // SUB
                        alu_control           = 3'b001;
                        register_write_enable = 1'b1;
                        writeback_select      = WB_ALU;
                        next_state            = STATE_FETCH;
                    end

                    4'b0011: begin // AND
                        alu_control           = 3'b010;
                        register_write_enable = 1'b1;
                        writeback_select      = WB_ALU;
                        next_state            = STATE_FETCH;
                    end

                    4'b0100: begin // OR
                        alu_control           = 3'b011;
                        register_write_enable = 1'b1;
                        writeback_select      = WB_ALU;
                        next_state            = STATE_FETCH;
                    end

                    4'b0101: begin // XOR
                        alu_control           = 3'b100;
                        register_write_enable = 1'b1;
                        writeback_select      = WB_ALU;
                        next_state            = STATE_FETCH;
                    end

                    4'b0110: begin // MOV
                        register_write_enable = 1'b1;
                        writeback_select      = WB_REGISTER;
                        next_state            = STATE_FETCH;
                    end

                    4'b0111: begin // LOAD
                        register_write_enable = 1'b1;
                        writeback_select      = WB_MEMORY;
                        next_state            = STATE_FETCH;
                    end

                    4'b1100: begin // LDI
                        register_write_enable = 1'b1;
                        writeback_select      = WB_IMMEDIATE;
                        next_state            = STATE_FETCH;
                    end

                    default: begin
                        next_state = STATE_HALT;
                    end

                endcase
            end

            // -------------------------------------------------
            // HALT
            // -------------------------------------------------
            STATE_HALT: begin
                halted     = 1'b1;
                next_state = STATE_HALT;
            end

            default: begin
                next_state = STATE_FETCH;
            end

        endcase
    end

endmodule
```
