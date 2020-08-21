module Mux4 #(width=4)( // Multiplexador de 4 entradas
	input logic a[width-1:0],	// Entrada 00
	input logic b[width-1:0],	// Entrada 01
	input logic c[width-1:0],	// Entrada 10
	input logic d[width-1:0],	// Entrada 11
	input logic s[1:0],			// Seletor 2 bits
	output logic o[width-1:0]	// Saida
);

integer i;		// Variavel auxiliar para a estrutura for (Não sintetizavel)

always_comb
	case(s)
	2'b00:o<=a;
	2'b01:o<=b;
	2'b10:o<=c;
	2'b11:o<=d;
	default:
		for(i=0;i<width;i++)		// Modelo necessario por conta do parametro
			o[i] = 1'b0;
	endcase

endmodule 