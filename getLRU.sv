module getlru #(WAYS = 8, WAYS_REP = 3)(
//input logic [INDEX-1:0]set,
input logic [WAYS-2:0]get_lru,         //LRU bits as input
output logic [WAYS_REP-1:0]way_getlru  //Way encoded in 3'binary.
);

always_comb
begin
if( get_lru[0]==0 ) 
begin
	if( get_lru[1]==0 )
	begin
		if ( get_lru[3]==0 )
		begin
		way_getlru=3'b000;
		end
		else
		begin
		way_getlru=3'b001;
		end
	end
	else
	begin
		if( get_lru[4]==0)
		begin
		way_getlru=3'b010;
		end
		else
		begin
		way_getlru=3'b011;
		end
	end
end
else
begin
	if( get_lru[2]==0 )
	begin
		if ( get_lru[5]==0 )
		begin
		way_getlru=3'b100;
		end
		else
		begin
		way_getlru=3'b101;
		end
	end
	else
	begin
		if( get_lru[6]==0)
		begin
		way_getlru=3'b110;
		end
		else
		begin
		way_getlru=3'b111;
		end
	end
end
end
endmodule



/*module updatelru #(WAYS_REP=3, WAYS=8) (
input logic [WAYS_REP-1:0]way_updatelru,   //Way encoded in 3bit
input logic [WAYS-1]plru   //incoming plru bits
output logic [WAYS-1]p; //updated plru
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
endcase
end
endmodule*/

