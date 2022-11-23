
module cache #(
// All are taken as local parm 
)(
	input logic 	   clk,
	input logic 	   rstb,
	input logic [31:0] address,
	input logic  [3:0] n
);

`include "Cache_struct.sv"
sets_nway_t [(NUM_OF_SETS-1):0] sets;
sets_nway_t [(NUM_OF_SETS-1):0] sets_nxt;
logic                           update_sets;
logic [(TAG-1):0]               tag_in;       
logic [(INDEX-1):0]             index_in;       
logic [(BYTE-1):0]              byte_offset_in;
logic [(WAYS_REP-1):0]          ways_in;

// decoding n
/*
0 read request from L1 data cache
1 write request from L1 data cache
2 read request from L1 instruction cache
3 snooped invalidate command
4 snooped read request
5 snooped write request
6 snooped read with intent to modify request
8 clear the cache and reset all state
9 print contents and state of each valid cache line (doesn?t end simulation!)
*/

// decode address
assign tag_in         = address[31:(INDEX-1)]; 
assign index_in       = address[(INDEX-1):(BYTE-1)];
assign byte_offset_in = address[(BYTE-1):0];

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

// CORE LOGIC starts from here
assign update_sets = 1'b1;  // FIXME : Build the combi logic for updating the sets based on LRU and MESI

// Creating flops for the whole cache
always_ff@(posedge clk or negedge rstb)
begin
	if(rstb==0)
	begin
		sets <= 0;
	end
	else if(update_sets)
	begin
		sets <= sets_nxt;
	end
	else
	begin
		sets <= sets;
	end
end

// Combi logic for the next signal; generate a update signal when all are ready to go inside the cache and check for updates

always_comb
begin
	sets_nxt[index_in].line[ways_in].tag = tag_in; 
	sets_nxt[index_in].line[ways_in].byte_select = byte_offset_in; 
end

endmodule