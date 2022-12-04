`include "Cache_struct.sv"
module cache #(
// All are taken as local parm 
)(
	input  logic 	        clk,
	input  logic 	        rstb,
	input  logic [31:0]     address,
	input  logic  [3:0]     n,
	input  logic 		valid,
	output logic [15:0]	hit_cntr,    // Counter to count the number of HITS
	output logic [15:0]     miss_cntr,   // Counter to count the number of MISS
	output bus_struct 	bus_func_out,
	output l2tol1_struct 	l2tol1msg_out,
	output logic [1:0]	C            // Modeling C in RTL
);

sets_nway_t [(NUM_OF_SETS-1):0] sets;
sets_nway_t [(NUM_OF_SETS-1):0] sets_nxt;

sets_nway_t    			set_disp;
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
logic 				cmpr_read_hit;

// Could have selected a vector but this will be easy i the waves
logic 				opr_1;
logic 				opr_2;
logic 				opr_1_pulse;
logic 				opr_2_pulse;

logic 				opr_finished;

logic 				sync_rstb; // This is when n = 8
logic 				rstb_comb; // created the combi logic to reset it

mesi_struct			mesi_states_in;   // Use this to update in cache
mesi_struct			mesi_states_out;  // Use this to update in FSM

logic 				valid_2d;	// 2 cycles delayed

// This modukle generates the necessary pulses for each module to operate

Cache_opr_ctrl i_opr_ctrl (
	.clk		(clk		),
	.rstb		(rstb_comb	),
	.valid		(valid		),
	.opr_finished	(opr_finished	),
	.opr_1		(opr_1		),
	.opr_2		(opr_2		),
	.opr_1_pulse	(opr_1_pulse	),
	.opr_2_pulse	(opr_2_pulse	),
	.valid_d	(valid_d	),
	.valid_2d	(valid_2d	)   // FIXME delete if not used
);

// Counter for HIt and Miss

always_ff@(posedge clk or negedge rstb_comb)
begin
	if(rstb_comb==0)
	begin
		hit_cntr  <= '0;
		miss_cntr <= '0;
	end
	else if (valid_d & (cmpr_read_hit))
	begin
		hit_cntr  <= hit_cntr + 1;
		miss_cntr <= miss_cntr;
	end
	else if (valid_d & (~cmpr_read_hit))
	begin
		hit_cntr  <= hit_cntr;
		miss_cntr <= miss_cntr + 1;
	end
	else 
	begin
		hit_cntr  <= hit_cntr;
		miss_cntr <= miss_cntr;
	end
end
// Model HIT HITM MISS COUT CIN DRAM READ REQUESTS BASED ON HIT AND MISS
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

// Reset block to be used for clearing the cache asynchronously 
always_comb
begin
	sync_rstb = ((n_in & valid) == CLR_CACHE_RST) ? 0 : 1;    // active low 
	rstb_comb = rstb & sync_rstb;			          // AND with the main reset; Initial bug analysis on rstb
end

// decode address
assign tag_in         = address[31:(INDEX+BYTE)]; 
assign index_in       = address[(INDEX+BYTE-1):BYTE];
assign byte_offset_in = address[(BYTE-1):0];

// Module to interface with each bit of LRU
/* Functions to implement : Cache_replacement_algorithm
	1. Update LRU bits --> Arguments required --> a) which set b) way that it hit
	2. Way to be replaced at eviction --> a) Which set
*/

// small module coded for the hit case so that it compares the
// tag incoming qnd exisitng and get the way from it : Cache_read_hit

assign read = ((n_in==READ_REQ_L1_D)|(n_in==READ_REQ_L1_I)|(n_in==WRITE_REQ_L1_D));

Cache_hit #(
	.WAYS_REP	(WAYS_REP	),
	.INDEX	        (INDEX		)
) i_read_hit (
	.clk		(clk		),
	.rstb		(rstb_comb	),
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
// FIXME needs to be updated based on updates in MESI

/*
	if      HIT   C_ == 00
	else if HITM  C == 01
	else	NOHIT C == 1X
*/

Cache_get_snoop_function i_snoop_func (
	.address	(address	),
	.C		(C		)
);

Cache_mesi_fsm#(

) i_mesi_fsm (
	.clk		(clk		),
	.rstb		(rstb_comb	),
	.C_in		(C		),
	.mesi_states_in	(mesi_states_in ),
	.valid		(valid		),
	.valid_d	(valid_d	),
	.nmsg_in	(n_in		),
	.mesi_states_out(mesi_states_out),
	.bus_func_out	(bus_func_out	),
	.l2tol1msg_out	(l2tol1msg_out	)
);

// CORE LOGIC starts from here


// Creating hier of cache
always_ff@(posedge clk or negedge rstb_comb)
begin
	if(rstb_comb==0)
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
// Inclusivity should be implemented: Evicting a line from L1 as well when L2 is eviciting

always_comb
begin
	sets_nxt = sets;
	update_sets = opr_1_pulse; // Update here sp that cache gets upated with actual values : FIXME
	// update_sets = (n_in==WRITE_REQ_L1_D)&(opr_finished); // Should add cases of evictions and stuff 
	// read miss then also we need to get it from cache
	sets_nxt[index_in].line[ways_in].tag = tag_in; 
	//sets_nxt[index_in].line[ways_in].byte_select = byte_offset_in; 
	plru_in = sets[index_in].plru;
	sets_nxt[index_in].plru = plru_out;
	opr_finished = opr_2_pulse;

	set_disp = sets[0];

// Instead of typecast :( replace it once you get to know how to type cast
	case(sets[index_in].line[ways_in].mesi)
		I:mesi_states_in=I;
		E:mesi_states_in=E;
		S:mesi_states_in=S;
		M:mesi_states_in=M;
		default:mesi_states_in=I;
	endcase

	case(mesi_states_out)
		I:sets_nxt[index_in].line[ways_in].mesi=I;
		E:sets_nxt[index_in].line[ways_in].mesi=E;
		S:sets_nxt[index_in].line[ways_in].mesi=S;
		M:sets_nxt[index_in].line[ways_in].mesi=M;
		default:sets_nxt[index_in].line[ways_in].mesi=I;
	endcase

end

endmodule

//
// POINTS TO IMPLEMENT
//
// Write to cache based on many events those events must be mentioned 
// HIT should happen only when it is not in invalid state add that condiition
// 
// Inclusivity should be maintaned 24 slide cache coherence
// slide 29 coherence also should check that
// L1 is dirty and it writes to L2 then L2 writes to DRAM upon eviciton 


