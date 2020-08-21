module StateMachine (
	input rst, input clk, 
	input mode_input, // button
	input cancel_input, // button
	//input up_input, // button - não é nenecessário para a maquina de estados
	//input down_input, //button - não é nenecessário para a maquina de estados
	input ok_input, // button
	input rst_3, // counter 3s reset pressed
	input alarm_match, // compare alarm register with clock
	input counter_end, // counter stopwatch is zero
	output buzer_output, // play buzzer
	output timer_output, // led  - determina o sign tbm - determina o display também
	output stopwatch_output, // led - determina o display também
	output alarm_on_output,	// era o led - 1 liga o alarme
	output alarm_off_output,	// 1 desliga o alarme
	output [1:0]count_sel, // mux sel - determina o copy - nao seleciona o display do timer
	output set_left,	// enable set left
	output set_right, // enable set right
	output blink_dots, // enable blink display - quando os dois lados estiverem sem alteração, os dois piscam
	output copy, // enable direct in
	output counting, // counting_enable
	output mst_rst, // master reset
	output cnt_rst  // counter stopwatch reset
	,output [4:0]temp_state
);

	//Estados da máquina
	enum int unsigned { clock_state=0, rst_state_hour=1, rst_state_min=2, pre_set_clock=3, pos_set_clock=4, // função relogio
								stopwatch_state=5, counter_state_up=6, rst_counter_state_up=7, 	// função cronometro
								timer_state_min=8, timer_state_sec=9, counter_state_down=10, rst_counter_state_down=11, // função temporizador
								alarm_state_hour=12, alarm_state_min=13, pre_set_alarm=14, pos_set_alarm=15, // funcção alarme
								alarm_state_active=16, timer_alarm_active=17 // buzzer
							} fstate, fnegstate, reg_fstate; // fstate - estado da máquina sincronizado na borda de subida, 
																		//fnegstate - estado da maquina sincronizado na borda de descida, 
																		//reg_fstate - próximo estado
																		
	localparam clock_display = 2'b000,
					set_clock_display = 2'b001,
					alarm_display = 2'b010,
					set_alarm_display = 2'b011;
	
	//reg alarm_active; // informa se o alarme esta ativo ou inativo // podemos substituir por um registrador no avaliador do alarme

	always_ff @(posedge clk) // fstate sincronizado na borda de subida - influenciado pelas entradas
	begin
		if (clk) begin
			fstate <= reg_fstate;
		end
	end
	
	always_ff @(negedge clk) // fnegstate sincronizado na borda de descida - influencia as saidas
	begin
		if (!clk) begin
			fnegstate <= fstate;
		end
		
		/* poderá sumir apos alteração no avaliador do alarme
		case (fstate)
		pre_set_clock:alarm_active<=1'b0;
		alarm_state_hour:alarm_active<=1'b0;
		pos_set_alarm:alarm_active<=1'b1;
		endcase
		*/
	end
    
	/*poderá sumir apos alteração no avaliador do alarme
	assign alarm_on_output = alarm_active;
	*/
	assign temp_state = fstate; // exibe temporariamente o estado da maquina na saida

	always_comb begin // O modo combinacional com as entradas e saidas garante a 
							// criação de registradores apenas para os estados, diminuindo e organizando o circuito
		if (rst) begin // Reset básico, retoma o estado de relógio
			reg_fstate <= clock_state;
            
			buzer_output<= 1'b0;
			timer_output<= 1'b0;
			stopwatch_output<= 1'b0;
			alarm_on_output<=1'b0;
			alarm_off_output<=1'b0;
			count_sel<= clock_display;
			set_left<= 1'b0;
			set_right<= 1'b0;
			blink_dots<= 1'b0;
			copy<= 1'b0;
			counting<= 1'b0;
			mst_rst<= 1'b0;
			cnt_rst<= 1'b1;
		end
		else if (rst_3) begin // reset_master, reinicializa todos os elementos do relógio
			reg_fstate <= pre_set_clock;
			
			buzer_output<= 1'b0;
			timer_output<= 1'b0;
			alarm_on_output<=1'b0;
			alarm_off_output<=1'b1; // desliga o alarme
			stopwatch_output<= 1'b0;
			count_sel<= clock_display;
			set_left<= 1'b0;
			set_right<= 1'b0;
			blink_dots<= 1'b0;
			copy<= 1'b0;
			counting<= 1'b0;
			mst_rst<= 1'b1; // reinicializa todos os contadores
			cnt_rst<= 1'b1;
            
			//alarm_active<=1'b0; // mst_rst desliga o alame tambem
		end
		else if (alarm_match) begin //  && alarm_active // Se o avaliador informar alarme igual
			reg_fstate <= alarm_state_active; // vai para o estado que ativa o buzzer
				
			buzer_output<= 1'b0;
			timer_output<= 1'b0;
			alarm_on_output<=1'b0;
			alarm_off_output<=1'b0;
			stopwatch_output<= 1'b0;
			count_sel<= clock_display;
			set_left<= 1'b0;
			set_right<= 1'b0;
			blink_dots<= 1'b0;
			copy<= 1'b0;
			counting<= 1'b0;
			mst_rst<= 1'b0;
			cnt_rst<= 1'b0;
		end
		else begin
			// Especifica um valor para todas as saidas para evitar criação de latches
			buzer_output<= 1'b0;
			timer_output<= 1'b0;
			stopwatch_output<= 1'b0;
			alarm_on_output<=1'b0;
			alarm_off_output<=1'b0;
			count_sel<= clock_display;
			set_left<= 1'b0;
			set_right<= 1'b0;
			blink_dots<= 1'b0;
			copy<= 1'b0;
			counting<= 1'b0;
			mst_rst<= 1'b0;
			cnt_rst<= 1'b0;
				
			// sincronizado na borda de subida,determina o próximo estado
			case (fstate)
				clock_state: begin
					if (mode_input)
						reg_fstate <= stopwatch_state;
					else
						reg_fstate <= clock_state;	
				end
				rst_state_hour: begin
					if (cancel_input)
						reg_fstate <= clock_state;
					else if (ok_input)
						reg_fstate <= rst_state_min;
					else
						reg_fstate <= rst_state_hour;	
				end
				rst_state_min: begin
					if (cancel_input)
						reg_fstate <= pre_set_clock;
					else if (ok_input)
						reg_fstate <= pos_set_clock;
					else
						reg_fstate <= rst_state_min;	
				end
				stopwatch_state: begin
					if (cancel_input)
						reg_fstate <= clock_state;
					else if (ok_input)
						reg_fstate <= counter_state_up;
					else if (mode_input)
						reg_fstate <= timer_state_min;
					else
						reg_fstate <= stopwatch_state;	
				end
				counter_state_up: begin
					if (cancel_input)
						reg_fstate <= rst_counter_state_up;
					else if (ok_input)
						reg_fstate <= stopwatch_state;
					else if (counter_end)
						reg_fstate <= stopwatch_state;
					else
						reg_fstate <= counter_state_up;	
				end
				timer_state_min: begin
					if (cancel_input)
						reg_fstate <= clock_state;
					else if (ok_input)
						reg_fstate <= timer_state_sec;
					else if (mode_input)
						reg_fstate <= pre_set_alarm;
					else
						reg_fstate <= timer_state_min;	
				end
				timer_state_sec: begin
					if (cancel_input)
						reg_fstate <= timer_state_min;
					else if (ok_input)
						reg_fstate <= counter_state_down;
					else if (mode_input)
						reg_fstate <= pre_set_alarm;
					else 
						reg_fstate <= timer_state_sec;	
				end            
				counter_state_down: begin
					if (cancel_input)
						reg_fstate <= rst_counter_state_down;
					else if (ok_input)
						reg_fstate <= timer_state_min;
					else if (counter_end)
						reg_fstate <= timer_alarm_active;
					else
						reg_fstate <= counter_state_down;	
				end
				timer_alarm_active: begin
					if (ok_input| cancel_input)
						reg_fstate <= timer_state_min;
					else
						reg_fstate <= timer_alarm_active;	
				end
				alarm_state_hour: begin
					if (ok_input)
						reg_fstate <= alarm_state_min;
					else if (cancel_input | mode_input)
						reg_fstate <= clock_state;
					else
						reg_fstate <= alarm_state_hour;	
				end
				alarm_state_min: begin
					if (cancel_input)
						reg_fstate <= pre_set_alarm;
					else if (mode_input)
						reg_fstate <= clock_state;
					else if (ok_input)
						reg_fstate <= pos_set_alarm;
					else
						reg_fstate <= alarm_state_min;	
				end
				alarm_state_active: begin
					if (ok_input | cancel_input)
				    	reg_fstate <= clock_state;
					else if (mode_input)
				    	reg_fstate <= pre_set_alarm;
					else
				    	reg_fstate <= alarm_state_active;	
				end
				pre_set_alarm: begin
					reg_fstate <= alarm_state_hour;	
				end
				pre_set_clock: begin
					reg_fstate <= rst_state_hour;	
				end
				pos_set_alarm: begin
					reg_fstate <= clock_state;
				end
				pos_set_clock: begin
					reg_fstate <= clock_state;	
				end
				rst_counter_state_up: begin
					reg_fstate <= stopwatch_state;	
				end
				rst_counter_state_down: begin
					reg_fstate <= timer_state_min;	
				end
				default: begin
				end
			endcase
			
			// Sincrinizado na borda de descida, determina o valor das saídas
			case (fnegstate)
				clock_state: begin
				end
				rst_state_hour: begin
					count_sel<= set_clock_display;
					set_left<= 1'b1;
					set_right<= 1'b0;
					blink_dots<= 1'b1;	
				end
				rst_state_min: begin
					count_sel<= set_clock_display;
					set_left<= 1'b0;
					set_right<= 1'b1;
					blink_dots<= 1'b1;	
				end
				stopwatch_state: begin
					stopwatch_output<= 1'b1;
					blink_dots<= 1'b1;
					counting<= 1'b0;
					cnt_rst<=1'b0;
				end
				counter_state_up: begin
					stopwatch_output<= 1'b1;
					blink_dots<= 1'b0;
					counting<= 1'b1;
				end
				timer_state_min: begin
					buzer_output<= 1'b0;
					timer_output<= 1'b1;
					set_left<= 1'b1;
					set_right<= 1'b0;
					blink_dots<= 1'b1;
					counting<= 1'b0;
				end
				timer_state_sec: begin
					buzer_output<= 1'b0;
					timer_output<= 1'b1;
					set_left<= 1'b0;
					set_right<= 1'b1;
					blink_dots<= 1'b1;
					counting<= 1'b0;
				end            
				counter_state_down: begin
					buzer_output<= 1'b0;
					timer_output<= 1'b1;
					set_left<= 1'b0;
					set_right<= 1'b0;
					blink_dots<= 1'b0;
					counting<= 1'b1;
				end
				timer_alarm_active: begin
					buzer_output<= 1'b1;
					timer_output<= 1'b1;
					set_left<= 1'b0;
					set_right<= 1'b0;
					blink_dots<= 1'b1;
					counting<= 1'b0;
					cnt_rst<=1'b1;
				end
				alarm_state_hour: begin
					count_sel<= set_alarm_display;
					set_left<= 1'b1;
					set_right<= 1'b0;
					blink_dots<= 1'b1;	
					
				end
				alarm_state_min: begin
					count_sel<= set_alarm_display;
					set_left<= 1'b0;
					set_right<= 1'b1;
					blink_dots<= 1'b1;
				end
				alarm_state_active: begin
					buzer_output<= 1'b1;
					blink_dots<= 1'b1;
				end
				pre_set_alarm: begin
					copy<= 1'b1;
					count_sel<= alarm_display;
					alarm_off_output<=1'b1; // desliga o alarme // alarm_active <= 1'b0; 
				end
				pre_set_clock: begin
					copy<= 1'b1;
					count_sel<= clock_display;
				end
				pos_set_alarm: begin
					alarm_on_output<=1'b1;// liga o alarme // alarm_active<=1'b1;	
					copy<= 1'b1;
					count_sel<= set_alarm_display;
				end
				pos_set_clock: begin
					copy<= 1'b1;
					count_sel<= set_clock_display;
				end
				rst_counter_state_up: begin
					cnt_rst <= 1'b1;
				end
				rst_counter_state_down: begin
					cnt_rst <= 1'b1;
				end
				default: begin
					buzer_output<= 1'bx;
					timer_output<= 1'bx;
					stopwatch_output<= 1'bx;
					set_left<= 1'bx;
					set_right<= 1'bx;
					blink_dots<= 1'bx;
					copy<= 1'bx;
					counting<= 1'bx;
					mst_rst<= 1'bx;
					cnt_rst<= 1'bx;
					$display ("Reach undefined state");
				end
            endcase
        end
    end
endmodule 