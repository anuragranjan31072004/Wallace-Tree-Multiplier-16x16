module wallace16 #(parameter N=16, parameter W=2*N, parameter MAX_OPS=32)(
 input wire [N-1:0] a,
 input wire [N-1:0] b,
 output wire [W-1:0] product
);
 localparam WW = W + 1;
 reg [WW-1:0] ops_init [0:N-1];
 integer i, j;

 always @(*) begin
  for (i=0; i<N; i=i+1)
   ops_init[i] = {WW{1'b0}};
  for (i=0; i<N; i=i+1)
   for (j=0; j<N; j=j+1)
    ops_init[i][j+i] = a[j] & b[i];
 end

 reg [WW-1:0] ops[0:MAX_OPS-1];
 reg [WW-1:0] next_ops[0:MAX_OPS-1];
 reg [7:0] op_count, next_count;
 integer pass, idx, t;
 reg [WW-1:0] s_vec, c_vec;

 always @(*) begin
  for (idx=0; idx<MAX_OPS; idx=idx+1)
   ops[idx] = (idx<N)? ops_init[idx] : {WW{1'b0}};
  op_count = N;

  for (pass=0; pass<MAX_OPS; pass=pass+1) begin
   if (op_count <= 2)
    pass = MAX_OPS - 1;
   else begin
    for (idx=0; idx<MAX_OPS; idx=idx+1)
     next_ops[idx] = {WW{1'b0}};
    next_count = 0;
    t = op_count / 3;

    for (idx=0; idx<t; idx=idx+1) begin
     s_vec = ops[3*idx] ^ ops[3*idx+1] ^ ops[3*idx+2];
     c_vec = ((ops[3*idx] & ops[3*idx+1]) |
              (ops[3*idx+1] & ops[3*idx+2]) |
              (ops[3*idx] & ops[3*idx+2])) << 1;
     next_ops[next_count++] = s_vec;
     next_ops[next_count++] = c_vec;
    end

    for (idx=3*t; idx<op_count; idx=idx+1)
     next_ops[next_count++] = ops[idx];

    for (idx=0; idx<MAX_OPS; idx=idx+1)
     ops[idx] = (idx<next_count)? next_ops[idx] : {WW{1'b0}};
    op_count = next_count;
   end
  end
 end

 wire [WW:0] final_sum;
 assign final_sum = (op_count==1)?
                    {1'b0, ops[0]} :
                    ({1'b0, ops[0]} + {1'b0, ops[1]});

 assign product = final_sum[W-1:0];
endmodule
