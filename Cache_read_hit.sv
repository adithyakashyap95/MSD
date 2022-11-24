`include "Cache_struct.sv"

module Cache_read_hit #(
	parameter 	WAYS_REP	= 3,
	parameter 	INDEX		= 3    // DONT FORGET TO OVERRIDE ELSE THIS WONT WORK	
)(
	input  logic 		     clk,
	input  logic 		     rstb,
	input  sets_nway_t 	     sets,
	input  logic     	     read,
	input  logic [(INDEX-1):0]   tag_in,
	output logic [WAYS_REP-1:0]  way,
	output logic 		     cmpr_read_hit
);

logic [WAYS_REP] cntr;
logic        	 cmpr_hit;

always_ff @(posedge clk or negedge rstb)
begin
	if(rstb==0)
		cntr <= 0;
	else if(!read)     // What all read should we choose for this : FIXME
		cntr <= 0;
	else if(cmpr_hit)
		cntr <= cntr;
	else
		cntr <= cntr + 1;
end

always_comb
begin
	cmpr_hit      = (set.line[cntr].tag == tag_in) ? 1: 0; 
	way           = (cmpr_hit == 1) ?  cntr : 0;
	cmpr_read_hit = cmpr_hit;
end

endmodule
