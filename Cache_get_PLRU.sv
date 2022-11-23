module Cache_get_PLRU #(
	parameter WAYS = 8, 
	parameter WAYS_REP = 3
)(
	//input  logic [INDEX-1:0]set,
	input  logic [(WAYS-1-1):0] get_lru,         //LRU bits as input
	output logic [WAYS_REP-1:0] way_getlru  //Way encoded in 3'binary.
);

always_comb
begin
	if( get_lru[0]==1 ) 
	begin
		if( get_lru[1]==1 )
		begin
			if ( get_lru[3]==1 )
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
			if( get_lru[4]==1)
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
		if( get_lru[2]==1 )
		begin
			if ( get_lru[5]==1 )
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
			if( get_lru[6]==1)
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
