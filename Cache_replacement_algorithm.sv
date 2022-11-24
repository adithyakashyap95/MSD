module Cache_replacement_algorithm #(
	parameter WAYS     = 8, 
	parameter WAYS_REP = 3
)(
	input  logic [WAYS-1-1:0]	plru_in,         
	output logic [WAYS-1-1:0]       plru_out,
	output logic [WAYS_REP-1:0]     ways,
	input  logic 			read,
	input  logic 			cmpr_read_hit,
	input  logic [WAYS_REP-1:0]     way_read_hit

);  

// Module to interface with each bit of LRU
/* Functions to implement
	1. Update LRU bits --> Arguments required --> a) which set b) way that it hit
	2. Way to be replaced at eviction --> a) Which set
*/
logic [WAYS_REP-1:0] ways_mid;

Cache_get_PLRU #(
	.WAYS		(WAYS         ), 
	.WAYS_REP 	(WAYS_REP     )
) i_get_plru (
	.get_lru        (plru_in      ),         //LRU bits as input
	.way_getlru     (ways_mid     )          //Way encoded in 3'binary.
);

assign ways = ((read && cmpr_read_hit)==1) ? way_read_hit : ways_mid;

Cache_update_PLRU #(
	.WAYS		(WAYS         ), 
	.WAYS_REP 	(WAYS_REP     )
) i_update_plru (
	.way_updatelru	(ways	      ),         //Way encoded in 3bit
	.plru		(plru_in      ),         //incoming plru bits
	.p              (plru_out     )          //updated plru
);

endmodule