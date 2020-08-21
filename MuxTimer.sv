module MuxTimer #(time_turn=3,time_turn_log=2,sel_qtd=4,sel_qtd_log=2,width=4)(//50000 16 4 2 8 // 3 2 4 2 4
	input clk, input _rst,
	input [sel_qtd-1:0][width-1:0]in_value,
	output [width-1:0]out_value,
	output [sel_qtd-1:0]out_sel
);
reg [time_turn_log-1:0]counter = 'b0;
reg [sel_qtd_log-1:0]sel = 'b0;
reg rst = 'b0;

always_comb begin
	out_value <= in_value[sel];
	out_sel <= ~(1<<sel);
end

always_ff @ (posedge clk)begin
	rst<= ~_rst;
end

always_ff @ (negedge clk)begin
	if(rst)begin
		counter <= 'b0;
		sel <= 'b0;
	end
	else begin
		if(counter == time_turn-1)begin
			counter <= 'b0;
			if(sel == sel_qtd-1)
				sel<='b0;
			else
				sel++;
		end
		else
			counter++;
	end
end
endmodule 