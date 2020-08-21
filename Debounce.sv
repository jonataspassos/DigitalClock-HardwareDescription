
// FPGA projects, Verilog projects, VHDL projects
// Verilog code for button debouncing on FPGA
// debouncing module 
module Debounce #(clock_f = 16, width=4)(
	input pb_1,clk,rst,
	output pb_out
);
	wire slow_clk;
	wire Q1,Q2,Q2_bar,Q0;

	ClockDiv #(clock_f,width) u1(clk,rst,slow_clk);
	my_dff d0(slow_clk, pb_1,Q0 );

	my_dff d1(slow_clk, Q0,Q1 );
	//my_dff d2(slow_clk, Q1,Q2 );

	//assign Q2_bar = ~Q2;
	assign pb_out = Q1;// & Q2_bar;
	
endmodule 



// D-flip-flop for debouncing module 
module my_dff(
	input DFF_CLOCK, D,
	output reg Q
);

    always @ (negedge DFF_CLOCK) begin
        Q <= D;
    end

endmodule 