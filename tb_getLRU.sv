module tb_getLRU();
logic [6:0] get_lru;         //LRU bits as input
logic [2:0] way_getlru; //Way encoded in 3'binary.
int i;
Cache_get_PLRU i1(.*);

initial
begin
for(i=0; i<128; i=i+1)
begin
#115;
get_lru = i;
#5;
$display("LRU bits = %b way= %b" ,get_lru, way_getlru);
end
end
endmodule