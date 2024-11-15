module new_s_is_gt #(
    parameter N = 7,
    parameter DATA_BITS = 8
) (
    input [DATA_BITS-1: 0] new_S,
    input [(N-1)*DATA_BITS-1 : 0]s,
    output reg [N-2 : 0] gts
);

    integer i;

    always @ (*) begin
        for (i = 0; i < N-1; i = i+1) begin
            gts[i] = new_S > s[DATA_BITS * i +: DATA_BITS];
        end
   end

endmodule

