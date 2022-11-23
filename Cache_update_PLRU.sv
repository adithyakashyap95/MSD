module Cache_update_PLRU #(
	parameter WAYS_REP=3, 
	parameter WAYS=8 
) (
	input  logic [WAYS_REP-1:0] way_updatelru,   //Way encoded in 3bit
	input  logic [WAYS-1]       plru,            //incoming plru bits
	output logic [WAYS-1]       p                //updated plru
);

always_comb
begin
	case(way_updatelru)
		3'b000 : p = (plru & 1110100);
		3'b001 : p = (plru & 1110100) | 7'b0001000;
		3'b010 : p = (plru & 1101100) | 7'b0000010;
		3'b011 : p = (plru & 1101100) | 7'b0010010;
		3'b100 : p = (plru & 1011010) | 7'b0000001;
		3'b101 : p = (plru & 1011010) | 7'b0100001;
		3'b110 : p = (plru & 0111010) | 7'b0000101;
		3'b111 : p = (plru & 0111010) | 7'b1000101;
		default: p = plru;
	endcase
end
endmodule
