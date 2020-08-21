module ValueMatcher # (width=4)(
	input clk, input rst,
	input turn_on,
	input turn_off,
	input set_value,
	input [width-1:0]value_in,
	output [width-1:0]value_out,
	output value_match,
	output turn_out
);
	reg [width-1:0]value_reg;
	reg set_value_reg;
	reg turn;
	
	always_ff @ (posedge clk) begin
		if(rst) begin
			value_reg <= {width{1'b0}};
			turn <= 1'b0;
		end
		else if (set_value)
			value_reg <= value_in;
		
		set_value_reg <= set_value;
		
		if (turn_off)
			turn <= 1'b0;
		else if (turn_on)
			turn <= 1'b1;
	end
	
	always_ff @ (negedge clk) begin
		value_out <= value_reg;
		turn_out <= turn;
		if(turn && ~set_value_reg && value_in == value_reg)
			value_match <= 1'b1;
		else
			value_match <= 1'b0;
	end
endmodule 