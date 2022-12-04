
module Cache_get_snoop_function (
	input  logic [31:0]	address,
	output logic [1:0]	C
);
/*
	LSB   SnoopResult

	00       HIT
	01       HITM
	10       NOHIT
	11       NOHIT
*/
	assign C = address[1:0];

endmodule

