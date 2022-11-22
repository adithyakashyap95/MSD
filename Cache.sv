
module cache #(
// All are taken as local parm 
)(
	input logic 	clk,
	input logic 	rstb
);

`include "Cache_struct.sv"
sets_nway_t [(NUM_OF_SETS-1):0] sets;
sets_nway_t [(NUM_OF_SETS-1):0] sets_nxt;

// Creating flops for the whole cache
always_ff@(posedge clk or negedge rstb)
begin
	if(rstb==0)
	begin
		sets <= 0;
	end
	else
	begin
		sets <= sets_nxt;
	end
end

// Module to interface with each bit of LRU
/* Functions to implement
	1. Update LRU bits --> Arguments required --> a) which set b) way that it hit
	2. Way to be replaced at eviction --> a) Which set
*/
// Module to interface each bit of MESI
/* Functions to implement
	1. Communicates to lower level cache and DRAM/memory controller
	2. Inclusivity propeties must be obeyed 
	3. coherence protocol.
	4. DATA transfer based on Hit and Miss.
	5. Monitor the snoop and give iut snoop result.
*/

endmodule