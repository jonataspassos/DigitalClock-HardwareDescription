module BuzerManager  #(time_on=12500000,time_on_log=24,half_period=15000,half_period_log=15)(
	input clk, input _rst,
	input in_button,
	output reg out_beep
);

reg turn;
reg [time_on_log-1:0]reg_time_on;
reg [half_period_log-1:0]reg_half_period;
reg rst;

always_ff @ (posedge clk)begin
	rst<= ~_rst;
end

always_ff @ (negedge clk)begin
	if(rst)begin
		turn=1'b0;
		reg_time_on='b0;
		reg_half_period='b0;
	end
	else begin
		if(in_button)begin
			if(turn)begin
				if(reg_half_period >= half_period-1)begin
					reg_half_period <= 'b0;
					out_beep <= ~out_beep;
				end
				else begin
					reg_half_period++;
				end
			end
			
			if(reg_time_on >= time_on-1)begin
				reg_time_on <= 'b0;
				turn <= ~turn;
			end
			else begin
				reg_time_on++;
			end
		
		end
	end
end

endmodule 