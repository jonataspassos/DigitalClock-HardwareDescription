module toplevel #(param_min_seg = 60, param_hour = 24, param_f_clk = 1)(
	input in_clock,
	input in_btn_rst,
	input rst_3,
	input in_btn_mode,
	input in_btn_cancel,
	input in_btn_up,
	input in_btn_down,
	input in_btn_ok,
	output out_led_alarm,
	output out_led_timer,
	output out_led_stopwatch,
	output [6:0]out_disp_left,
	output [6:0]out_disp_right,
	output out_buzzer,
	output out_led_dots
	,output [4:0]state_machine
);

wire wire_rst_mst;
wire wire_general_parse_1sec;
wire wire_clock_parse_1min;
wire wire_clock_parse_1hour;
wire wire_timer_counting_flag;
wire wire_timer_or_stopwatch_sel;
wire wire_alarm_match;
wire wire_btn_up_or_down;
wire wire_cnt_timer_rst;
wire wire_copy_set;
wire wire_over_100min_timer;
wire wire_over_timer_1min;

wire [1:0]bus2_disp_sel;//00 clock 01 set_clock 10 alarm 11 set_alarm
wire [1:0]bus2_alarm_turn;//10 ligar 01 desligar
wire [1:0]bus2_set_left_right;//10 set_left 01 set_rigth
wire [4:0]bus5_clock_hour;
wire [4:0]bus5_set_clock_hour;
wire [4:0]bus5_alarm_hour;
wire [4:0]bus5_set_alarm_hour;
wire [6:0]bus7_timer_min;
wire [5:0]bus6_clock_min;
wire [5:0]bus6_set_clock_min;
wire [5:0]bus6_clock_sec;
wire [5:0]bus6_alarm_min;
wire [5:0]bus6_set_alarm_min;
wire [5:0]bus6_timer_sec;

assign wire_timer_or_stopwatch_sel = out_led_stopwatch || out_led_timer;
assign wire_btn_up_or_down = in_btn_down || in_btn_up;

Mux #(.width(7),.qtd(8),.sel(3))
	mux_disp_left(
		.A( { { 3 {7'b0}}, bus7_timer_min , {2'b0,bus5_set_alarm_hour} , {2'b0,bus5_alarm_hour} , {2'b0,bus5_set_clock_hour} , {2'b0,bus5_clock_hour} } ),//[qtd-1:0][width-1:0]
		.S( {wire_timer_or_stopwatch_sel,bus2_disp_sel} ),//[sel-1:0]
		.O( out_disp_left )//[width-1:0]
	), mux_disp_right(
		.A( { { 3 {7'b0}}, {1'b0,bus6_timer_sec} , {1'b0,bus6_set_alarm_min} , {1'b0,bus6_alarm_min} , {1'b0,bus6_set_clock_min} , {1'b0,bus6_clock_min} } ),//[qtd-1:0][width-1:0]
		.S( {wire_timer_or_stopwatch_sel,bus2_disp_sel} ),//[sel-1:0]
		.O( out_disp_right )//[width-1:0]
	);

StateMachine stm (
	.rst( in_btn_rst ),
	.clk( in_clock ),
	.mode_input( in_btn_mode ),
	.cancel_input( in_btn_cancel ),
	.ok_input( in_btn_ok ),
	.rst_3( rst_3 ),	/* Não definido */
	.alarm_match( wire_alarm_match && wire_general_parse_1sec ), 
	.counter_end( ( ( out_led_timer && ( {bus7_timer_min,bus6_timer_sec} == 'b0 ) ) || 
						( out_led_stopwatch && wire_over_100min_timer) ) 
				&& wire_timer_counting_flag),
	.buzer_output( out_buzzer ),
	.timer_output( out_led_timer ),
	.stopwatch_output( out_led_stopwatch ),
	.alarm_on_output( bus2_alarm_turn[1] ),
	.alarm_off_output( bus2_alarm_turn[0] ),
	.count_sel( bus2_disp_sel ),
	.set_left( bus2_set_left_right[1] ),
	.set_right( bus2_set_left_right[0] ),
	.blink_dots( out_led_dots ), /* Não definido */
	.copy( wire_copy_set ),
	.counting( wire_timer_counting_flag ),
	.mst_rst( wire_rst_mst ),
	.cnt_rst( wire_cnt_timer_rst )
	,.temp_state( state_machine )
);

CounterBasic #(.width(26),.compare(param_f_clk))
	counterbasic_1sec(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.over_value( wire_general_parse_1sec )
	);

Counter #(.width(5),.compare_reset(param_hour))
	counter_clock_hour(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.count( wire_clock_parse_1hour ),
		.sign( 1'b0 ),
		.direct_in_enable( (bus2_disp_sel==2'b01) && wire_copy_set ),
		.direct_in( out_disp_left[4:0] ),
		.out_value( bus5_clock_hour )
		//.over_value(  )
	), counter_set_clock_hour(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.count( wire_btn_up_or_down && (bus2_disp_sel==2'b01) && bus2_set_left_right[1] ),
		.sign( in_btn_down ),
		.direct_in_enable( (bus2_disp_sel==2'b00) && wire_copy_set ),
		.direct_in( out_disp_left[4:0] ),
		.out_value( bus5_set_clock_hour )
		//.over_value(  )
	), counter_set_alarm_hour(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.count( wire_btn_up_or_down && (bus2_disp_sel==2'b11) && bus2_set_left_right[1] ),
		.sign( in_btn_down ),
		.direct_in_enable( (bus2_disp_sel==2'b10) && wire_copy_set ),
		.direct_in( out_disp_left[4:0] ),
		.out_value( bus5_set_alarm_hour )
		//.over_value(  )
	);
Counter #(.width(6),.compare_reset(param_min_seg))
	counter_clock_min(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.count( wire_clock_parse_1min ),
		.sign( 1'b0 ),
		.direct_in_enable( (bus2_disp_sel==2'b01) && wire_copy_set ),
		.direct_in( out_disp_right[5:0] ),
		.out_value( bus6_clock_min ),
		.over_value( wire_clock_parse_1hour )
	), counter_set_clock_min(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.count( wire_btn_up_or_down && (bus2_disp_sel==2'b01) && bus2_set_left_right[0] ),
		.sign( in_btn_down ),
		.direct_in_enable( (bus2_disp_sel==2'b00) && wire_copy_set ),
		.direct_in( out_disp_right[5:0] ),
		.out_value( bus6_set_clock_min )
		//.over_value(  )
	), counter_set_alarm_min(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.count( wire_btn_up_or_down && (bus2_disp_sel==2'b11) && bus2_set_left_right[0] ),
		.sign( in_btn_down ),
		.direct_in_enable( (bus2_disp_sel==2'b10) && wire_copy_set ),
		.direct_in( out_disp_right[5:0] ),
		.out_value( bus6_set_alarm_min )
		//.over_value(  )
	), counter_clock_sec(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.count( wire_general_parse_1sec ), 
		.sign( 1'b0 ),
		.direct_in_enable( 1'b0 ),
		.direct_in( 6'b0 ),
		.out_value( bus6_clock_sec ),
		.over_value( wire_clock_parse_1min )
	), counter_timer_sec(
		.clk( in_clock ),
		.rst( wire_rst_mst || wire_cnt_timer_rst ),
		.count( ( wire_timer_counting_flag && wire_general_parse_1sec ) || 
				(!wire_timer_counting_flag && out_led_timer && wire_btn_up_or_down && bus2_set_left_right[0])),
		.sign( wire_timer_counting_flag? out_led_timer : in_btn_down ), // quando o timer estiver ativo, ele conta pra baixo
		//.direct_in_enable(  ),
		//.direct_in(  ),
		.out_value( bus6_timer_sec ),
		.over_value( wire_over_timer_1min )
	);
Counter #(.width(7),.compare_reset(100))
	counter_timer_min(
		.clk( in_clock ),
		.rst( wire_rst_mst || wire_cnt_timer_rst ),
		.count( ( wire_timer_counting_flag && wire_over_timer_1min ) || 
				(!wire_timer_counting_flag && out_led_timer && wire_btn_up_or_down && bus2_set_left_right[1]) ),
		.sign( wire_timer_counting_flag? out_led_timer : in_btn_down ),
		.direct_in_enable( 1'b0 ),
		.direct_in( 7'b0 ),
		.out_value( bus7_timer_min ),
		.over_value( wire_over_100min_timer ) // Deverá parar contagem do cronômetro
	);

ValueMatcher # (.width(17))
	matcher_alarm(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.turn_on( bus2_alarm_turn[1] ),
		.turn_off( bus2_alarm_turn[0] ),
		.set_value( (bus2_disp_sel==2'b11) && wire_copy_set ),
		.value_in( ( (bus2_disp_sel==2'b11) && wire_copy_set ) ?
			{out_disp_left[4:0],out_disp_right[5:0],6'b0} :
				{ bus5_clock_hour,bus6_clock_min,bus6_clock_sec } ),
		.value_out( {bus5_alarm_hour,bus6_alarm_min,6'b0} ),
		.value_match( wire_alarm_match ),
		.turn_out( out_led_alarm )
	);
endmodule 