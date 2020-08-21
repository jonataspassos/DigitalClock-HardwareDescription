module HexDisplay ( // binary to display (Baixo ativo)
	input logic _enable,
	input logic [3:0]binary_in,
	output logic [6:0]display_out
);
always_comb
	if(!_enable)
		case(binary_in)
		0: display_out <= 7'h01;
		1: display_out <= 7'h4f;
		2: display_out <= 7'h12;
		3: display_out <= 7'h06;
		4: display_out <= 7'h4c;
		5: display_out <= 7'h24;
		6: display_out <= 7'h20;
		7: display_out <= 7'h0f;
		8: display_out <= 7'h00;
		9: display_out <= 7'h04;
		10:display_out <= 7'h08;
		11:display_out <= 7'h60;
		12:display_out <= 7'h30;
		13:display_out <= 7'h42;
		14:display_out <= 7'h30;
		15:display_out <= 7'h38;
		default:display_out <= {7{1'b1}};
		endcase
	else
		display_out <= {7{1'b1}};
endmodule 