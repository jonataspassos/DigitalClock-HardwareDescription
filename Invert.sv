module Invert(
	input clk,
	input rst,
	input in_value,
	output reg out_value
);

reg neg_rst;
reg neg_value;

always_ff @ (posedge clk) begin
	neg_rst <= rst;
	neg_value <= in_value;
end

always_ff @ (negedge clk) begin
	if(neg_rst)
		out_value<=1'b0;
	else
		if(neg_value)
			out_value<=~out_value;
end

endmodule