
module cache #(
// All are taken as local parm 
)(
	input logic 	        clk,
	input logic 	        rstb,
	input logic [31:0]      address,
	input logic  [3:0]      n
);

`include "Cache_struct.sv"

sets_nway_t [(NUM_OF_SETS-1):0] sets;
sets_nway_t [(NUM_OF_SETS-1):0] sets_nxt;
n_t				n_in;
logic                           update_sets;
logic [(TAG-1):0]               tag_in;       
logic [(INDEX-1):0]             index_in;       
logic [(BYTE-1):0]              byte_offset_in;
logic [WAYS_REP-1:0]            ways_in; 
logic [WAYS-1-1:0]	 	plru_in;        
logic [WAYS-1-1:0]       	plru_out;
logic [WAYS_REP-1:0]        	way_read_hit;
logic 				read;

logic 				PrRd;
logic 				PrWr;
logic 				BusUpgr_in;
logic 				BusRd_in;
logic 				BusRdX_in;
logic 				C_in;
logic 				BusUpgr_out;
logic 				BusRd_out;
logic 				BusRdX_out;
logic 				Flush;

// Decode n with enum logic 
always_comb
begin
	case(n)
		0:n_in = READ_REQ_L1_D;
  		1:n_in = WRITE_REQ_L1_D;
  		2:n_in = READ_REQ_L1_I;
  		3:n_in = SNOOP_INVALID_CMD;
  		4:n_in = SNOOP_READ_REQ;
  		5:n_in = SNOOP_WRITE_REQ;
  		6:n_in = SNOOP_READ_WITH_M;
  		8:n_in = CLR_CACHE_RST;
  		9:n_in = PRINT_CONTENTS;
		default:n_in = PRINT_CONTENTS;     // Considering the if invalid commands to print             
	endcase
end

// decode address
assign tag_in         = address[31:(INDEX-1)]; 
assign index_in       = address[(INDEX-1):(BYTE-1)];
assign byte_offset_in = address[(BYTE-1):0];

// Module to interface with each bit of LRU
/* Functions to implement : Cache_replacement_algorithm
	1. Update LRU bits --> Arguments required --> a) which set b) way that it hit
	2. Way to be replaced at eviction --> a) Which set
*/

//small module to be coded for the Read hit case so that it compares the
// tag incoming qnd exisitng and get the way from it : Cache_read_hit

assign read = ((n==READ_REQ_L1_D)|(n==READ_REQ_L1_I)|(n==WRITE_REQ_L1_D));

Cache_hit #(
	.WAYS_REP	(WAYS_REP	),
	.INDEX	        (INDEX		)
) i_read_hit (
	.clk		(clk		),
	.rstb		(rstb		),
	.sets		(sets[index_in] ),
	.read		(read		),
	.tag_in		(tag_in		),
	.way		(way_read_hit	),
	.cmpr_read_hit	(cmpr_read_hit	)
);

Cache_replacement_algorithm #(
	.WAYS		(WAYS		), 
	.WAYS_REP	(WAYS_REP	)
) i_plru (
	.plru_in	(plru_in	),         
	.plru_out	(plru_out	),
	.ways		(ways_in	),
	.read		(read		),
	.way_read_hit 	(way_read_hit	),
	.cmpr_read_hit	(cmpr_read_hit  )
);

// Module to interface each bit of MESI
/* Functions to implement
	1. Communicates to lower level cache and DRAM/memory controller
	2. Inclusivity propeties must be obeyed 
	3. coherence protocol.
	4. DATA transfer based on Hit and Miss.
	5. Monitor the snoop and give iut snoop result.
*/

Cache_mesi_fsm#(

) i_mesi_fsm (
	.clk		(clk		),
	.rstb		(rstb		),
	.PrRd		(PdRd		),
	.PrWr		(PrWr 		),
	.BusUpgr_in	(BusUpgr_in	),
	.BusRd_in	(BusRd_in	),
	.BusRdX_in	(BusRdX_in	),
	
	.C_in		(C_in		),
	.BusUpgr_out	(BusUpgr_out	),
	.BusRd_out	(BusRd_out	),
	.BusRdX_out	(BusRdX_out	),
	.Flush		(Flush		)
);

// CORE LOGIC starts from here
assign update_sets = 1'b0;  // FIXME : Build the combi logic for updating the sets based on LRU and MESI

// Creating flops for the whole cache
always_ff@(posedge clk or negedge rstb)
begin
	if(rstb==0)
	begin
		sets <= 0;
	end
	else if(update_sets)
	begin
		sets <= sets_nxt; // update here FIXME
	end
	else
	begin
		sets <= sets;
	end
end

// Combi logic for the next signal; generate a update signal when all are ready to go inside the cache and check for updates
// Update below combi logic which is wrong
// FIXME

always_comb
begin
	sets_nxt[index_in].line[ways_in].tag = tag_in; 
	sets_nxt[index_in].line[ways_in].byte_select = byte_offset_in; 
end

endmodule