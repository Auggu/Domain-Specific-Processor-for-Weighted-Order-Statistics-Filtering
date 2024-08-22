module top_button_clk (
	input clk,
    input button1,
    input button2,
    output [6:0] sev_seg0,
	output [6:0] sev_seg1,
	output [6:0] sev_seg2,
	output [6:0] sev_seg3
);

    parameter N = 3;
    parameter data_bits = 8;
    parameter rank_bits = $clog2(N);
	parameter RANK_SEL = N/2;
	 
	wire [data_bits-1 : 0] out;
	 
	assign rst = button2;

	debounce #(20) deb(clk, !button1, fake_clk);

	//rom 
	wire [data_bits-1 : 0] i_new;
	reg [7:0] addr = 0;
	always @(posedge fake_clk or negedge rst) begin
		if(!rst)
			addr <= 0;
		else
			addr <= addr + 1;
	end 


	Rom rom(addr, fake_clk, i_new);
	 
    rank_order #(N, data_bits, rank_bits, RANK_SEL) rof (fake_clk, rst, i_new, out);
	 
    seven_seg ss0(out[3:0], sev_seg0);
	seven_seg ss1(out[7:4], sev_seg1);
	 
	seven_seg ss2(i_new[3:0], sev_seg2);
	seven_seg ss3(i_new[7:4], sev_seg3);

endmodule