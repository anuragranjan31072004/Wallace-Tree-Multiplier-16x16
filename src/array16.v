module array16 (
 input wire [15:0] a,
 input wire [15:0] b,
 output wire [31:0] product
);
 assign product = a * b;
endmodule
