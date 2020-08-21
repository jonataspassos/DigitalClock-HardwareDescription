module relogio #(param_min_seg = 60, param_hour = 24, param_f_clk = 50000000)(
	input in_clock,
	input in_btn_rst,
	input in_btn_mode,
	input in_btn_cancel,
	input in_btn_up,
	input in_btn_down,
	input in_btn_ok,
	output out_led_alarm,
	output out_led_timer,
	output out_led_stopwatch,
	output [7:0]out_disp,
	output [3:0]out_sel,
	output out_buzzer
	//,output [4:0]state_machine
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
wire wire_debounced_rst;
wire wire_debounced_mode;
wire wire_debounced_cancel;
wire wire_debounced_up;
wire wire_debounced_down;
wire wire_debounced_ok;
wire wire_managed_rst;
wire wire_managed_rst3;
wire wire_managed_mode;
wire wire_managed_cancel;
wire wire_managed_up;
wire wire_managed_down;
wire wire_managed_ok;
wire wire_compare_rst;
wire wire_led_blink;
wire wire_led_blinking;
wire wire_buzer_status;
wire wire_led_alarm;
wire wire_led_timer;
wire wire_led_stopwatch;

wire [1:0]bus2_disp_sel;//00 clock 01 set_clock 10 alarm 11 set_alarm
wire [1:0]bus2_alarm_turn;//10 ligar 01 desligar
wire [1:0]bus2_dots;//1 - dots left; 0 - dots right;
wire [1:0]bus2_set_left_right;//10 set_left 01 set_rigth
wire [3:0]bus4_compare_flags;// 3 - 5s; 2 - 3s; 1 - 1s, 0 - 0.5 s;
wire [3:0]bus4_left_disp_1;
wire [3:0]bus4_left_disp_0;
wire [3:0]bus4_right_disp_1;
wire [3:0]bus4_right_disp_0;
wire [4:0]bus5_rst_functions;// 4 - 5s; 3 - 3s; 2 - 3cl; 1 - 2cl; 0 - 1cl;
wire [4:0]bus5_clock_hour;
wire [4:0]bus5_set_clock_hour;
wire [4:0]bus5_alarm_hour;
wire [4:0]bus5_set_alarm_hour;
wire [5:0]bus6_clock_min;
wire [5:0]bus6_set_clock_min;
wire [5:0]bus6_clock_sec;
wire [5:0]bus6_alarm_min;
wire [5:0]bus6_set_alarm_min;
wire [5:0]bus6_timer_sec;
wire [6:0]bus6_disp_left;
wire [6:0]bus6_disp_right;
wire [6:0]bus7_timer_min;
wire [6:0]bus7_disp_3;
wire [6:0]bus7_disp_2;
wire [6:0]bus7_disp_1;
wire [6:0]bus7_disp_0;

assign wire_timer_or_stopwatch_sel = wire_led_stopwatch || wire_led_timer;
assign wire_btn_up_or_down = wire_managed_down || wire_managed_up;
assign wire_managed_rst = bus5_rst_functions[0] || bus5_rst_functions[1] || bus5_rst_functions[2];
assign wire_managed_rst3 = bus5_rst_functions[3] || bus5_rst_functions[4];
assign bus2_dots[1] = ~(wire_led_blink && bus2_set_left_right[1] || wire_led_blink && bus2_set_left_right==2'b00);
assign bus2_dots[0] = ~(wire_led_blink && bus2_set_left_right[0] || wire_led_blink && bus2_set_left_right==2'b00);
assign out_led_alarm = ~wire_led_alarm;
assign out_led_timer = ~wire_led_timer;
assign out_led_stopwatch = ~wire_led_stopwatch;

CounterCompare #(.width(28),.compare_1_value(25000000), .compare_2_value(50000000), .compare_3_value(150000000), .compare_reset(250000000))
	compare_matcher_rst (
		.clk(in_clock),
		.rst(~wire_compare_rst),
		.compare_1(bus4_compare_flags[0]),//meio segundo
		.compare_2(bus4_compare_flags[1]),//1 segundos
		.compare_3(bus4_compare_flags[2]),//3 segundos
		.over_value(bus4_compare_flags[3])//5 segundos
	);

Debounce #(.clock_f(param_f_clk), .width(26))
	deb_rst_circuit (
		.pb_1(in_btn_rst),
		.clk(in_clock),
		.rst(wire_rst_mst),
		.pb_out(wire_debounced_rst)
	),deb_mode_circuit (
		.pb_1(in_btn_mode),
		.clk(in_clock),
		.rst(wire_managed_rst),
		.pb_out(wire_debounced_mode)
	),deb_cancel_circuit(
		.pb_1(in_btn_cancel),
		.clk(in_clock),
		.rst(wire_managed_rst),
		.pb_out(wire_debounced_cancel)
	),deb_up_circuit(
		.pb_1(in_btn_up),
		.clk(in_clock),
		.rst(wire_managed_rst),
		.pb_out(wire_debounced_up)
	),deb_down_circuit(
		.pb_1(in_btn_down),
		.clk(in_clock),
		.rst(wire_managed_rst),
		.pb_out(wire_debounced_down)
	),deb_ok_circuit(
		.pb_1(in_btn_ok),
		.clk(in_clock),
		.rst(wire_managed_rst),
		.pb_out(wire_debounced_ok)
	);

BtnSimpleManage 
	manage_mode_circuit(
		.clock(in_clock),
		.rst(wire_managed_rst),
		.button(~wire_debounced_mode),
    	.click(wire_managed_mode)
	),manage_cancel_circuit(
		.clock(in_clock),
		.rst(wire_managed_rst),
		.button(~wire_debounced_cancel),
    	.click(wire_managed_cancel)
	),manage_up_circuit(
		.clock(in_clock),
		.rst(wire_managed_rst),
		.button(~wire_debounced_up),
    	.click(wire_managed_up)
	),manage_down_circuit(
		.clock(in_clock),
		.rst(wire_managed_rst),
		.button(~wire_debounced_down),
    	.click(wire_managed_down)
	),manage_ok_circuit(
		.clock(in_clock),
		.rst(wire_managed_rst),
		.button(~wire_debounced_ok),
    	.click(wire_managed_ok)
	);

BtnManage 
	manage_rst_circuit(
		.rst(wire_rst_mst),
		.clock(in_clock),
		.button(~wire_debounced_rst),
		.sec_half(bus4_compare_flags[0]),
		.sec_3(bus4_compare_flags[2]),
		.sec_5(bus4_compare_flags[3]),
		.click_1(bus5_rst_functions[0]),
		.click_2(bus5_rst_functions[1]),
		.click_3(bus5_rst_functions[2]),
		.click_3s(bus5_rst_functions[3]),
		.click_5s(bus5_rst_functions[4]),
		.cnt_rst(wire_compare_rst)
	);

Mux #(.width(7),.qtd(8),.sel(3))
	mux_disp_left(
		.A( { { 3 {7'b0}}, bus7_timer_min , {2'b0,bus5_set_alarm_hour} , {2'b0,bus5_alarm_hour} , {2'b0,bus5_set_clock_hour} , {2'b0,bus5_clock_hour} } ),//[qtd-1:0][width-1:0]
		.S( {wire_timer_or_stopwatch_sel,bus2_disp_sel} ),//[sel-1:0]
		.O( bus6_disp_left )//[width-1:0]
	), mux_disp_right(
		.A( { { 3 {7'b0}}, {1'b0,bus6_timer_sec} , {1'b0,bus6_set_alarm_min} , {1'b0,bus6_alarm_min} , {1'b0,bus6_set_clock_min} , {1'b0,bus6_clock_min} } ),//[qtd-1:0][width-1:0]
		.S( {wire_timer_or_stopwatch_sel,bus2_disp_sel} ),//[sel-1:0]
		.O( bus6_disp_right )//[width-1:0]
	);

StateMachine stm (
	.rst( wire_managed_rst ),
	.clk( in_clock ),
	.mode_input( wire_managed_mode ),
	.cancel_input( wire_managed_cancel ),
	.ok_input( wire_managed_ok ),
	.rst_3( wire_managed_rst3 ),	/* Não definido */
	.alarm_match( wire_alarm_match && wire_general_parse_1sec ), 
	.counter_end( ( ( wire_led_timer && ( {bus7_timer_min,bus6_timer_sec} == 'b0 ) ) || 
						( wire_led_stopwatch && wire_over_100min_timer) ) 
				&& wire_timer_counting_flag),
	.buzer_output( wire_buzer_status ),
	.timer_output( wire_led_timer ),
	.stopwatch_output( wire_led_stopwatch ),
	.alarm_on_output( bus2_alarm_turn[1] ),
	.alarm_off_output( bus2_alarm_turn[0] ),
	.count_sel( bus2_disp_sel ),
	.set_left( bus2_set_left_right[1] ),
	.set_right( bus2_set_left_right[0] ),
	.blink_dots( wire_led_blink ), /* Não definido */
	.copy( wire_copy_set ),
	.counting( wire_timer_counting_flag ),
	.mst_rst( wire_rst_mst ),
	.cnt_rst( wire_cnt_timer_rst )
	//,.temp_state( state_machine )
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
		.direct_in( bus6_disp_left[4:0] ),
		.out_value( bus5_clock_hour )
		//.over_value(  )
	), counter_set_clock_hour(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.count( wire_btn_up_or_down && (bus2_disp_sel==2'b01) && bus2_set_left_right[1] ),
		.sign( wire_managed_down ),
		.direct_in_enable( (bus2_disp_sel==2'b00) && wire_copy_set ),
		.direct_in( bus6_disp_left[4:0] ),
		.out_value( bus5_set_clock_hour )
		//.over_value(  )
	), counter_set_alarm_hour(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.count( wire_btn_up_or_down && (bus2_disp_sel==2'b11) && bus2_set_left_right[1] ),
		.sign( wire_managed_down ),
		.direct_in_enable( (bus2_disp_sel==2'b10) && wire_copy_set ),
		.direct_in( bus6_disp_left[4:0] ),
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
		.direct_in( bus6_disp_right[5:0] ),
		.out_value( bus6_clock_min ),
		.over_value( wire_clock_parse_1hour )
	), counter_set_clock_min(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.count( wire_btn_up_or_down && (bus2_disp_sel==2'b01) && bus2_set_left_right[0] ),
		.sign( wire_managed_down ),
		.direct_in_enable( (bus2_disp_sel==2'b00) && wire_copy_set ),
		.direct_in( bus6_disp_right[5:0] ),
		.out_value( bus6_set_clock_min )
		//.over_value(  )
	), counter_set_alarm_min(
		.clk( in_clock ),
		.rst( wire_rst_mst ),
		.count( wire_btn_up_or_down && (bus2_disp_sel==2'b11) && bus2_set_left_right[0] ),
		.sign( wire_managed_down ),
		.direct_in_enable( (bus2_disp_sel==2'b10) && wire_copy_set ),
		.direct_in( bus6_disp_right[5:0] ),
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
				(!wire_timer_counting_flag && wire_led_timer && wire_btn_up_or_down && bus2_set_left_right[0])),
		.sign( wire_timer_counting_flag? wire_led_timer : wire_managed_down ), // quando o timer estiver ativo, ele conta pra baixo
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
				(!wire_timer_counting_flag && wire_led_timer && wire_btn_up_or_down && bus2_set_left_right[1]) ),
		.sign( wire_timer_counting_flag? wire_led_timer : wire_managed_down ),
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
			{bus6_disp_left[4:0],bus6_disp_right[5:0],6'b0} :
				{ bus5_clock_hour,bus6_clock_min,bus6_clock_sec } ),
		.value_out( {bus5_alarm_hour,bus6_alarm_min,6'b0} ),
		.value_match( wire_alarm_match ),
		.turn_out( wire_led_alarm )
	);

BinaryBCD 
	left_bcd_circuit(
		.binary_in(bus6_disp_left),
		.bcd_out({bus4_left_disp_1,bus4_left_disp_0})
	),right_bcd_circuit(
		.binary_in(bus6_disp_right),
		.bcd_out({bus4_right_disp_1,bus4_right_disp_0})
	);

Invert
	blink_circuit(
	.clk(in_clock),
	.rst(wire_managed_rst),
	.in_value(wire_general_parse_1sec),
	.out_value(wire_led_blinking)
);

HexDisplay 
	left_disp_1_circuit(
		._enable(wire_led_blinking && ~bus2_dots[1]),
		.binary_in(bus4_left_disp_1),
		.display_out(bus7_disp_3)
	),left_disp_0_circuit(
		._enable(wire_led_blinking && ~bus2_dots[1]),
		.binary_in(bus4_left_disp_0),
		.display_out(bus7_disp_2)
	),right_disp_1_circuit(
		._enable(wire_led_blinking && ~bus2_dots[0]),
		.binary_in(bus4_right_disp_1),
		.display_out(bus7_disp_1)
	),right_disp_0_circuit(
		._enable(wire_led_blinking && ~bus2_dots[0]),
		.binary_in(bus4_right_disp_0),
		.display_out(bus7_disp_0)
	);

MuxTimer #(.time_turn(50000),.time_turn_log(16),.sel_qtd(4),.sel_qtd_log(2),.width(8))
	mux_disp_out_circuit(
		.clk(in_clock),
		._rst(~wire_managed_rst),
		.in_value({ { bus2_dots[1], bus7_disp_3}, 
					{ bus2_dots[1], bus7_disp_2}, 
					{ bus2_dots[0], bus7_disp_1}, 
					{ bus2_dots[0], bus7_disp_0} }),
		.out_value(out_disp),
		.out_sel(out_sel)
	);

BuzerManager  #(.time_on(12500000),.time_on_log(24),.half_period(15000),.half_period_log(15))
	buzer_manager_circuit(
		.clk(in_clock),
		._rst(~wire_managed_rst),
		.in_button(wire_buzer_status),
		.out_beep(out_buzzer)
	);
endmodule