module test ();

parameter N = 9;
parameter MASK_BITS = N*N;
parameter integer MASK_BYTES = $ceil(MASK_BITS / 8.0);
parameter MEM_SIZE = 4 + MASK_BYTES;

initial begin
  $display(MASK_BYTES);
end

endmodule
