// Slow clock for debouncing 
module ClockDiv#(clock_f = 50000000, width=26)(
	input Clk,
	input rst,
	output reg slow_clk
);
    reg [width-1:0]counter=0;
	 
    always @(negedge Clk)
    begin
		if(rst)
			counter<='b0;
		else begin
        counter <= (counter>=clock_f/4 -1)?0:counter+1;
        slow_clk <= (counter < clock_f/8)?1'b0:1'b1;
		end
    end
	 
endmodule