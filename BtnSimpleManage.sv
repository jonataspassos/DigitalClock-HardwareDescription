module BtnSimpleManage (
    input rst,
	 input clock,
	 input button,
    output click
	 //,output [3:0]temp_state,output [3:0]temp_reg_state
);

    enum int unsigned { initial_state=0,
		pressed=1, keep_pressed=2} fstate, fnegstate, reg_fstate;
		
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
            click <= 1'b0;
        end
        else begin
            click <= 1'b0;
            case (fstate)
                initial_state: begin
                    if (button)
                        reg_fstate <= pressed;
                    else
                        reg_fstate <= initial_state;
                end
                pressed: begin
                    reg_fstate <= keep_pressed;
                end
                keep_pressed: begin
                    if (~button)
                        reg_fstate <= initial_state;
                    else
                        reg_fstate <= keep_pressed;
                end
                default: begin
                    $display ("Reach undefined state");
                end
            endcase
			case (fnegstate)
                initial_state: begin
                end
                pressed: begin
                    click <= 1'b1;
                end
                keep_pressed: begin
                end
                default: begin
                    click <= 1'bx;
                    $display ("Reach undefined state");
                end
            endcase
        end
    end
endmodule 