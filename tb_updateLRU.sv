module tb_updateLRU();
logic [2:0]way_updatelru;   //Way encoded in 3bit
logic [6:0]plru;  //incoming plru bits
logic [6:0]p;
int i,j;

updatelru i1(.*);
initial
begin
for(i=0; i<8; i=i+1)
begin
	way_updatelru = i;	
		for(j=0; j<128; j=j+1)
		begin
		#10;
		plru = j;
		#1;
		$display(" way = %b , plru = %b, p=%b", way_updatelru, plru, p);
		#10;
		end
	#10;

end
end
endmodule

