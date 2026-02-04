module tb_wallace;
 reg [15:0] a, b;
 wire [31:0] prod_wallace, prod_array;
 integer i, seed, errors;
 reg [31:0] golden;

 wallace16 dut_wallace (.a(a), .b(b), .product(prod_wallace));
 array16 dut_array (.a(a), .b(b), .product(prod_array));

 initial begin
  $dumpfile("wallace_tb.vcd");
  $dumpvars(0, tb_wallace);
  errors = 0;
  seed = 32'hDEADBEEF;

  a=0; b=0; #5; check();
  a=16'hFFFF; b=16'h0001; #5; check();
  a=16'h1234; b=16'h5678; #5; check();

  for (i=0; i<1000; i=i+1) begin
   a = $random(seed);
   b = $random(seed);
   #1;
   check();
  end

  if(errors==0)
   $display("All tests passed!");
  else
   $display("Errors=%0d", errors);

  $finish;
 end

 task check;
 begin
  golden = a * b;
  if (prod_wallace !== golden) begin
   $display("Mismatch: %h × %h => W:%h G:%h",
             a, b, prod_wallace, golden);
   errors = errors + 1;
  end
 end
 endtask
endmodule
