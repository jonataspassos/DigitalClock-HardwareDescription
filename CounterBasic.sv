module CounterBasic #(width = 4,compare = 10)(
	input logic clk,
	input logic rst,
	output logic over_value
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
					if(count_value == compare-1)
						count_value<='b0;
					else
						count_value <= count_value + 'b1;
					
				endcase;
        end
    end

always_ff @ (negedge clk)
	over_value <= (count_value == compare-1) ? 1'b1 : 1'b0;
		
	 
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