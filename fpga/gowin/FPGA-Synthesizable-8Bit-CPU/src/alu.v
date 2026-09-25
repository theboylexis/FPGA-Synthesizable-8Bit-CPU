module alu (
    input wire [7:0] operand_a,
    input wire [7:0] operand_b,
    input wire [2:0] alu_control,

    output wire [7:0] result,
    output wire       zero_flag,
    output wire       carry_flag,
    output wire       negative_flag
);

    reg [8:0] alu_result;

    always @(*) begin
        case (alu_control)
            3'b000: begin
                alu_result = {1'b0, operand_a} + {1'b0, operand_b}; // ADD
            end

            3'b001: begin
                alu_result = {1'b0, operand_a} - {1'b0, operand_b}; // SUB
            end

            3'b010: begin
                alu_result = {1'b0, operand_a & operand_b}; // AND
            end

            3'b011: begin
                alu_result = {1'b0, operand_a | operand_b}; // OR
            end

            3'b100: begin
                alu_result = {1'b0, operand_a ^ operand_b}; // XOR
            end

            default: begin
                alu_result = 9'b0;
            end
        endcase
    end

    assign result = alu_result[7:0];

    assign zero_flag = (result == 8'b0);

    assign negative_flag = result[7];

    assign carry_flag = alu_result[8];

endmodule