
module cache #(
// All are taken as local parm 
)(
	input  logic 	        clk,
	input  logic 	        rstb,
	input  logic [31:0]     address,
	input  logic  [3:0]     n,
	input  logic 		valid,
	output logic [15:0]	hit_cntr,   // Counter to count the number of HITS
	output logic [15:0]     miss_cntr   // Counter to count the number of MISS
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
logic 				cmpr_read_hit;

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
logic				C_out;

// Could have selected a vector but this will be easy i the waves
logic 				opr_1;
logic 				opr_2;
logic 				opr_3;
logic 				opr_4;
logic 				opr_5;
logic 				opr_6;
logic 				opr_7;
logic 				opr_8;
logic 				opr_1_pulse;
logic 				opr_2_pulse;
logic 				opr_3_pulse;
logic 				opr_4_pulse;
logic 				opr_5_pulse;
logic 				opr_6_pulse;
logic 				opr_7_pulse;
logic 				opr_8_pulse;

logic 				opr_finished;

logic 				sync_rstb; // This is when n = 8
logic 				rstb_comb; // created the combi logic to reset it

mesi_struct			mesi_states_in;   // Use this to update in cache
mesi_struct			mesi_states_out;  // Use this to update in FSM

logic 				valid_2d;	// 2 cycles delayed

// This modukle generates the necessary pulses for each module to operate
// FIXME: Give this output to 
Cache_opr_ctrl i_opr_ctrl (
	.clk		(clk		),
	.rstb		(rstb_comb	),
	.valid		(valid		),
	.opr_finished	(opr_finished	),
	.opr_1		(opr_1		),
	.opr_2		(opr_2		),
	.opr_3		(opr_3		),
	.opr_4		(opr_4		),
	.opr_5		(opr_5		),
	.opr_6		(opr_6		),
	.opr_7		(opr_7		),
	.opr_8		(opr_8		),
	.opr_1_pulse	(opr_1_pulse	),
	.opr_2_pulse	(opr_2_pulse	),
	.opr_3_pulse	(opr_3_pulse	),
	.opr_4_pulse	(opr_4_pulse	),
	.opr_5_pulse	(opr_5_pulse	),
	.opr_6_pulse	(opr_6_pulse	),
	.opr_7_pulse	(opr_7_pulse	),
	.opr_8_pulse	(opr_8_pulse	),
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
	else if (opr_finished & (cmpr_read_hit))
	begin
		hit_cntr  <= hit_cntr + 1;
		miss_cntr <= miss_cntr;
	end
	else if (opr_finished & (~cmpr_read_hit))
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

//small module to be coded for the Read hit case so that it compares the
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
Cache_mesi_fsm#(

) i_mesi_fsm (
	.clk		(clk		),
	.rstb		(rstb_comb	),
	.PrRd		(PrRd		),
	.PrWr		(PrWr 		),
	.BusUpgr_in	(BusUpgr_in	),
	.BusRd_in	(BusRd_in	),
	.BusRdX_in	(BusRdX_in	),
	.C_in		(C_in		),
	.mesi_states_in	(mesi_states_in ),
	.valid		(valid		),

	.BusUpgr_out	(BusUpgr_out	),
	.BusRd_out	(BusRd_out	),
	.BusRdX_out	(BusRdX_out	),
	.Flush		(Flush		),
	.C_out 		(C_out		),
	.mesi_states_out(mesi_states_out)
);

// CORE LOGIC starts from here

// Creating flops for the whole cache
always_ff@(posedge clk or negedge rstb_comb)
begin
	if(rstb_comb==0)
	begin
		sets <= 0;
	end
	else if(update_sets)// update here FIXME
	begin
		sets <= sets_nxt; 
	end
	else
	begin
		sets <= sets;
	end
end

// Combi logic for the next signal; generate a update signal when all are ready to go inside the cache and check for updates
// Update below combi logic which is wrong
// FIXME : How to write to cache coming in..... Think on this 

always_comb
begin
	sets_nxt = sets;
	update_sets = opr_1_pulse; // Update here sp that cache gets upated with actual values : FIXME
	//update_sets = (n_in==WRITE_REQ_L1_D)&(opr_finished); // Should add cases of evictions and stuff 
	// read miss then also we need to get it from cache
	sets_nxt[index_in].line[ways_in].tag = tag_in; 
	//sets_nxt[index_in].line[ways_in].byte_select = byte_offset_in; 
	plru_in = sets[index_in].plru;
	sets_nxt[index_in].plru = plru_out;


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
// should implement the output in series like opr_1 then opr_2 then opr_3
// HIT should happen only when it is not in invalid state add that condiition
// 
// Inclusivity should be maintaned 24 slide cache coherence
// slide 29 coherence also should check that
// Operations should be performed in order using opr_ wires
// inference of MESI state diagrams like evictions and write or read
// L1 is dirty and it writes to L2 then L2 writes to DRAM upon eviciton 


