module Mux #(width=2,qtd=8,sel=3)(
	input logic [qtd-1:0][width-1:0]A,
	input logic [sel-1:0]S,
	output logic [width-1:0]O
);
assign O = A[S];
	

endmodule 