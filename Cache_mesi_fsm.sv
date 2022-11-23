module Caache_mesi_fsm(
input  logic 	clk,
input  logic 	rstb,
input  logic 	PrRd,
input  logic 	PrWr,
input  logic 	BusUpgr_in,
input  logic 	BusRd_in,
input  logic 	BusRdX_in,
output logic 	C_in,
output logic 	BusUpgr_out,
output logic 	BusRd_out,
output logic 	BusRdX_out,
output logic 	Flush
);

mesi_states_t currentstate, nextstate;

always_ff @(posedge clk)
	if(!rstb)
		currentstate <= I;
	else
		currentstate <= nextstate;

always_comb
   case(currentstate)
	M : if(PrRd | PrWr)
	    begin
		nextstate = M;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
	   end
	    else if(BusRd_in)
	    begin
		nextstate   = S;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 1;
	   end
			
	    else if(BusRdX_in)
	    begin
		nextstate   = I;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 1;
	    end
			

	E : if(PrRd)
	    begin
		nextstate = E;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
	    end

	    else if(PrWr)
	    begin
		nextstate   = M;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
	    end
			
	    else if(BusRd_in)
	    begin
		nextstate   = S;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
	    end
			
	    else if(BusRdX_in)
	    begin
		nextstate   = I;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
	    end

	S : if(PrRd)
	    begin
		nextstate = S;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
	    end

	    else if(PrWr)
	    begin
		nextstate   = M;
			BusUpgr_out = 1;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
	    end

	    else if(BusRd_in)
	    begin
		nextstate   = S;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
	    end

	    else if(BusRdX_in | BusUpgr_in)
	    begin
		nextstate   = I;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
	    end

	I : 	if(BusRd_in | BusRdX_in | BusUpgr_in)
		begin
			nextstate   = I;
				BusUpgr_out = 0;
				BusRd_out   = 0;
				BusRdX_out  = 0;
				Flush	    = 0;
		end

		else if(PrRd)
		begin
			if(C_in)
			begin
			nextstate = S;
				BusUpgr_out = 0;
				BusRd_out   = 1;
				BusRdX_out  = 0;
				Flush	    = 0;
			end
			else
			begin
			nextstate = E;
				BusUpgr_out = 0;
				BusRd_out   = 1;
				BusRdX_out  = 0;
				Flush	    = 0;
			end
		end

		else if(PrWr)
		begin
		nextstate   = M;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 1;
			Flush	    = 0;
		end

	default: nextstate = I;
   endcase
			
endmodule