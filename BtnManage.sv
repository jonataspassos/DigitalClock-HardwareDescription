module BtnManage (
    input rst,
	 input clock,
	 input button,
	 input sec_half,
	 input sec_3,
	 input sec_5,
    output click_1,
	 output click_2,
	 output click_3,
	 output click_3s,
	 output click_5s,
	 output cnt_rst
	 //,output [3:0]temp_state,output [3:0]temp_reg_state
);

    enum int unsigned { initial_state=0,
		pressed_1=1, keep_pressed_3=2, temp_keep_3=3, keep_pressed_5=4, keep_pressed=5,
		temp_released_1=6, released_1=7, temp_release_1=8, 
		pressed_2=9, released_2=10, temp_pressed_2=11,
		pressed_3=12, released_3=13
		} fstate, fnegstate, reg_fstate;
		
	//assign temp_state = fstate;
	//assign temp_reg_state = reg_fstate;

    always_ff @(posedge clock)
    begin
        if (clock) begin
            fstate <= reg_fstate;
        end
    end
	 
	 always_ff @(negedge clock)
    begin
        if (!clock) begin
            fnegstate <= fstate;
        end
    end

    always_comb begin
        if (rst) begin
            reg_fstate <= initial_state;
            click_1 <= 1'b0;
            click_2 <= 1'b0;
            click_3 <= 1'b0;
            click_3s <= 1'b0;
            click_5s <= 1'b0;
            cnt_rst <= 1'b0;
        end
        else begin
            click_1 <= 1'b0;
            click_2 <= 1'b0;
            click_3 <= 1'b0;
            click_3s <= 1'b0;
            click_5s <= 1'b0;
            cnt_rst <= 1'b0;
            case (fstate)
                initial_state: begin
                    if (button)
                        reg_fstate <= pressed_1;
                    else
                        reg_fstate <= initial_state;
                end
                pressed_1: begin
                    if (sec_3 & button)
                        reg_fstate <= keep_pressed_3;
                    else if (~button)
                        reg_fstate <= temp_released_1;
                    else
                        reg_fstate <= pressed_1;
                end
                keep_pressed_3: begin
                    if (~button)
                        reg_fstate <= temp_keep_3;
                    else if (sec_5 & button)
                        reg_fstate <= keep_pressed_5;
                    else
                        reg_fstate <= keep_pressed_3;
                end
                temp_keep_3: begin
                    reg_fstate <= initial_state;
                end
                keep_pressed_5: begin
                    reg_fstate <= keep_pressed;
                end
                keep_pressed: begin
                    if (~(button))
                        reg_fstate <= initial_state;
                    else
                        reg_fstate <= keep_pressed;
                end
                temp_released_1: begin
                    reg_fstate <= released_1;
                end
                released_1: begin
                    if (sec_half & ~(button))
                        reg_fstate <= temp_release_1;
                    else if (button)
                        reg_fstate <= pressed_2;
                    else
                        reg_fstate <= released_1;
                end
                temp_release_1: begin
                    reg_fstate <= initial_state;
                end
                pressed_2: begin
                    if (~button)
                        reg_fstate <= released_2;
                    else
                        reg_fstate <= pressed_2;
                end
                released_2: begin
                    if (button)
                        reg_fstate <= pressed_3;
                    else if (sec_half & ~(button))
                        reg_fstate <= temp_pressed_2;
                    else
                        reg_fstate <= released_2;
                end
                temp_pressed_2: begin
                    reg_fstate <= initial_state;
                end
                pressed_3: begin
                    if (~button)
                        reg_fstate <= released_3;
                    else
                        reg_fstate <= pressed_3;
                end
                released_3: begin
                    reg_fstate <= initial_state;
                end
                default: begin
                    $display ("Reach undefined state");
                end
            endcase
			case (fnegstate)
                initial_state: begin
                    cnt_rst <= 1'b0;
                end
                pressed_1: begin
                    cnt_rst <= 1'b1;
                end
                keep_pressed_3: begin
						cnt_rst <= 1'b1;
                end
                temp_keep_3: begin
                    click_3s <= 1'b1;
                end
                keep_pressed_5: begin
                    click_5s <= 1'b1;
                end
                keep_pressed: begin
                end
                temp_released_1: begin
                    cnt_rst <= 1'b0;
                end
                released_1: begin
                    cnt_rst <= 1'b1;
                end
                temp_release_1: begin
                    click_1 <= 1'b1;
                end
                pressed_2: begin
                    cnt_rst <= 1'b0;
                end
                released_2: begin
                    cnt_rst <= 1'b1;
                end
                temp_pressed_2: begin
                    click_2 <= 1'b1;
                end
                pressed_3: begin
                    cnt_rst <= 1'b0;
                end
                released_3: begin
                    click_3 <= 1'b1;
                end
                default: begin
                    click_1 <= 1'bx;
                    click_2 <= 1'bx;
                    click_3 <= 1'bx;
                    click_3s <= 1'bx;
                    click_5s <= 1'bx;
                    cnt_rst <= 1'bx;
                    $display ("Reach undefined state");
                end
            endcase
        end
    end
endmodule 