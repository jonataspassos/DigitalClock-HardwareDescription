module CounterCompare #(width = 4,compare_1_value = 2, compare_2_value = 4, compare_3_value=8, compare_reset = 10)(
	input logic clk,
	input logic rst,
	output logic compare_1, compare_2, compare_3, over_value
);

enum int unsigned { reset_state=0, inc_state=1} state, next_state;

reg [width-1:0]count_value;
integer i;

always_ff @(posedge clk)
    begin
        if (clk) begin
            state <= next_state;
				case(state)
				reset_state:
					count_value<='b0;
				
				inc_state:
					if(count_value == compare_reset-1)
						count_value<='b0;
					else
						count_value <= count_value + 'b1;
					
				endcase;
        end
    end

always_ff @ (negedge clk) begin
	compare_1 <= (count_value == compare_1_value-1) ? 1'b1 : 1'b0;
	compare_2 <= (count_value == compare_2_value-1) ? 1'b1 : 1'b0;
	compare_3 <= (count_value == compare_3_value-1) ? 1'b1 : 1'b0;
	over_value <= (count_value == compare_reset-1) ? 1'b1 : 1'b0;
end
		
	 
always_comb 
	if (rst)
      next_state <= reset_state;
   else begin
		case(state)
		reset_state: next_state <= inc_state;
		inc_state: next_state <= inc_state;
		
		endcase;
	end

endmodule 