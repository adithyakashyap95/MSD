`include "Cache_struct.sv"

module Cache_hit #(
	parameter 	WAYS_REP	= 3,
	parameter 	INDEX		= 3    // DONT FORGET TO OVERRIDE ELSE THIS WONT WORK	
)(
	input  logic 		     clk,
	input  logic 		     rstb,
	input  sets_nway_t 	     sets,
	input  logic [(TAG-1):0]     tag_in,
	output logic [WAYS_REP-1:0]  way,
	output logic 		     cmpr_read_hit
);

logic [WAYS_REP-1:0] cntr;
logic        	     cmpr_hit;

// Delay it accordingly

always_comb
begin
	if(((sets.line[0].tag)==tag_in) & (sets.line[0].mesi != I))
	begin
		cntr = 0;
		cmpr_hit = 1;
	end
	else if (((sets.line[1].tag)==tag_in) & (sets.line[1].mesi != I))
	begin
		cntr = 1;
		cmpr_hit = 1;
	end
	else if (((sets.line[2].tag)==tag_in) & (sets.line[2].mesi != I))
	begin
		cntr = 2;	
		cmpr_hit = 1;
	end
	else if (((sets.line[3].tag)==tag_in) & (sets.line[3].mesi != I))
	begin
		cntr = 3;
		cmpr_hit = 1;
	end
	else if (((sets.line[4].tag)==tag_in) & (sets.line[4].mesi != I))
	begin
		cntr = 4;
		cmpr_hit = 1;
	end
	else if (((sets.line[5].tag)==tag_in) & (sets.line[5].mesi != I))
	begin
		cntr = 5;
		cmpr_hit = 1;
	end
	else if (((sets.line[6].tag)==tag_in) & (sets.line[6].mesi != I))
	begin
		cntr = 6;
		cmpr_hit = 1;
	end
	else if (((sets.line[7].tag)==tag_in) & (sets.line[7].mesi != I))
	begin 
		cntr = 7;
		cmpr_hit = 1;
	end
	else 
	begin
		cntr = 0;
		cmpr_hit = 0;
	end
end

always_comb
begin
	//cmpr_hit      = (set.line[cntr].tag == tag_in) ? 1: 0; 
	way           = (cmpr_hit == 1) ?  cntr : 0;
	cmpr_read_hit = cmpr_hit;
end

endmodule
