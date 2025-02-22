module top_rank_order_filter (
	input clk,
    input button1,
    input button2,
	 input button3,
    output [6:0] sev_seg0,
	output [6:0] sev_seg1,
	output [6:0] sev_seg2,
	output [6:0] sev_seg3
);

    parameter N = 301;
    parameter data_bits = 8;
    parameter rank_bits = $clog2(N);
	 parameter RANK_SEL = N/2;
	 parameter NO_INPUT = 255;
	 
	wire [data_bits-1 : 0] out;
	assign run = addr < NO_INPUT;
	

	debounce #(20) deb1(clk, !button1, read_down);
	debounce #(20) deb2(clk, !button2, read_up);
	debounce #(20) deb3(clk, button3, rst);
	
	//rom 
	
	wire [data_bits-1 : 0] i_new;
	reg [7:0] addr = 0;
	always @(negedge run_clk or negedge rst) begin
		if(!rst)
			addr <= 0;
		else
			addr <= addr + 1;
	end 

	assign run_clk = run ? clk : 0;
	rom rom(addr, run_clk, i_new);
	
	//ram
	reg [7:0] rdaddr = 0;
	wire [7:0] ram_o;
	ram ram(clk, out, rdaddr, addr, run, ram_o);
	always @ (posedge read_up or negedge rst) begin
		if(!rst)
			rdaddr <= 0;
		else begin
			if(read_down)
				rdaddr <= rdaddr - 1;
			else
				rdaddr <= rdaddr +1;
		end
	end
	
    //rank_order #(N, data_bits, rank_bits, RANK_SEL) rof (run_clk, rst, rom_buffer, out);
	  rank_order #(N, data_bits, rank_bits, RANK_SEL) rof (run_clk, rst, i_new, out);
	 
    seven_seg ss0(ram_o[3:0], sev_seg0);
	seven_seg ss1(ram_o[7:4], sev_seg1);
	 
	seven_seg ss2(rdaddr[3:0], sev_seg2);
	seven_seg ss3(rdaddr[7:4], sev_seg3);

endmodule
