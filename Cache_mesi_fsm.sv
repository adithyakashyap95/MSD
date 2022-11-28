`include "Cache_struct.sv"

module Cache_mesi_fsm(
input  logic  clk, 			//clock signal
input  logic  rstb, 			//Active low reset signal
input  logic  PrRd,			//Processor-side(CPU) read signal
input  logic  PrWr,			//Processor-side(CPU) write signal
input  logic  BusUpgr_in,		//Bus Upgrade/Invalidate input signal
input  logic  BusRd_in,			//Bus Read input signal
input  logic  BusRdX_in,		//Bus read Exclusive input signal
input  logic  C_in,			//An active low input signal when asserted displays
					//that other caches has that cache line

input  mesi_struct mesi_states_in,	//Input signals from cache to MESI logic

output logic  BusUpgr_out,		//Bus Upgrade/Invalidate output signal
output logic  BusRd_out,		//Bus Read output signal
output logic  BusRdX_out,		//Bus read Exclusive output signal
output logic  Flush,			//Flush signal-asserted high when sending an entire cache line back to DRAM
output logic  C_out,			//An output signal asserted to display
					//that the cache has that cache line
output mesi_struct mesi_states_out	//Input signals from cache to MESI logic after update

);

// `include "Cache_struct.sv"

mesi_t currentstate, nextstate;

assign mesi_states_out = currentstate;


//MESI FSM starts
always_ff @(posedge clk)
	if(!rstb)
	begin
		currentstate <= I;
		
	end
	else
	begin
		currentstate <= nextstate;
		
	end

always_comb
   case(currentstate)
	M : if(PrRd | PrWr)
	    begin
		nextstate = M;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;
	    end
	    else if(BusRd_in)
	    begin
		nextstate   = S;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 1;
			C_out	    = 0;
	    end
			
	    else if(BusRdX_in)
	    begin
		nextstate   = I;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 1;
			C_out	    = 0;
	    end
	    
	    else
	    begin
	    	nextstate   = M;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;
	    end

			

	E : if(PrRd)
	    begin
		nextstate = E;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;
	    end

	    else if(PrWr)
	    begin
		nextstate   = M;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;
	    end
			
	    else if(BusRd_in)
	    begin
		nextstate   = S;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;
	    end
			
	    else if(BusRdX_in)
	    begin
		nextstate   = I;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;
	    end

	    else
	    begin
	    	nextstate   = E;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;
	    end

	S : if(PrRd)
	    begin
		nextstate = S;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 1;
	    end

	    else if(PrWr)
	    begin
		nextstate   = M;
			BusUpgr_out = 1;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;
	    end

	    else if(BusRd_in)
	    begin
		nextstate   = S;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;
	    end

	    else if(BusRdX_in | BusUpgr_in)
	    begin
		nextstate   = I;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;
	    end

	    else
	    begin
	    	nextstate   = S;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;
	    end

	I : 	if(BusRd_in | BusRdX_in | BusUpgr_in)
		begin
			nextstate   = I;
				BusUpgr_out = 0;
				BusRd_out   = 0;
				BusRdX_out  = 0;
				Flush	    = 0;
				C_out	    = 0;
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
				C_out	    = 0;
			end
			else
			begin
			nextstate = E;
				BusUpgr_out = 0;
				BusRd_out   = 1;
				BusRdX_out  = 0;
				Flush	    = 0;
				C_out	    = 0;
			end
		end

		else if(PrWr)
		begin
		nextstate   = M;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 1;
			Flush	    = 0;
			C_out	    = 0;
		end

	        else
	        begin
	    	nextstate   = I;
			BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;
	        end


	default: nextstate = I;
   endcase

//MESI FSM ends
			
endmodule