module sanity_test (
    input  wire a,
    input  wire b,
    output wire y
);

    assign y = a ^ b;

endmodule