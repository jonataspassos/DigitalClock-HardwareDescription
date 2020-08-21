module Counter #(width=4,compare_reset=10)(// Compara a saída para reset automatico
	input logic clk,		// posedge clock
	input logic rst,		// reset baixo ativo sincrono
	input logic count,	// contador sincrono
	input logic sign, 	// direcionador de contagem (0 + , 1 -)
	input logic direct_in_enable, // habilita o valor de entrada direta
	input logic [width-1:0]direct_in, // Especifica o valor de entrada direta
	output logic [width-1:0]out_value, // Saída do contador
	output logic over_value // sinaliza o reinício da contagem
);

reg [width-1:0]count_value; // armazena o valor de contagem
reg posedge_count; // auxilia na sinalização de reinício

enum int unsigned { reset_state=0, inc_state=1} state, next_state; // estados do contador

assign over_value = posedge_count && count; // Atribuição para sinalização de reinicio

always_ff @ (negedge clk )begin 	// Sinalização sincronizada com a borda de descida
	out_value <= count_value;					// Atricuição de valor do contador
	if(sign)								//	garante a resposta sincronizada dos contadores em cadeia
		if( count_value == 0 )
			posedge_count <= 1'b1;	// Sinaliza quando chega a 0
		else
			posedge_count <= 1'b0;
	else
		if( count_value >= compare_reset - 1 ) // Sinaliza quando chega ao valor de comparação
			posedge_count <= 1'b1;
		else
			posedge_count <= 1'b0;
end


always_comb begin
	
	if (rst)					// Configura os valores do próximo estado (garante um reset Síncrono)
      next_state <= reset_state;
   else 
		case(state)
		reset_state: next_state <= inc_state;
		inc_state: next_state <= inc_state;
		
		endcase;
end

always_ff @ (posedge clk)begin
	
	state <= next_state;	// Atribui o próximo estado
	
	case (state)
	reset_state: count_value<='b0;	// Zera a contagem
	inc_state: begin
		if (direct_in_enable)			// Atribuição direta de valor
			count_value <= direct_in;
		else if (count)					// Incremento/Decremento Ativo
			if(sign)
				if( count_value == 0 || count_value >= compare_reset) // Retorna para o máximo
					count_value <= compare_reset - 1;
				else
					count_value <= count_value + {width{1'b1}}; // Decrementa (soma -1 em complemento de 2)
			else 
				if( count_value >= compare_reset - 1 ) // Retorna a 0
					count_value <= 0;
				else
					count_value <= count_value + 1'b1; // Incrementa
	end
	endcase
end
	
endmodule 