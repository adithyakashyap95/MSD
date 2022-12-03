`include "Cache_struct.sv"

// NISHKA FIXME : REPLACE THE OUTPUT/INPUT PORT WITH OUTPUT/INPUT ENUM LOGIC: REFER cache_struct.sv

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
input  logic  valid,
input n_struct nmsg_in,

output logic  BusUpgr_out,		//Bus Upgrade/Invalidate output signal
output logic  BusRd_out,		//Bus Read output signal
output logic  BusRdX_out,		//Bus read Exclusive output signal
output logic  Flush,			//Flush signal-asserted high when sending an entire cache line back to DRAM
output logic  C_out,			//An output signal asserted to display
					//that the cache has that cache line
output mesi_struct mesi_states_out,	//Input signals from cache to MESI logic after update

output bus_struct bus_func_out,
output l2tol1_struct l2tol1msg_out
);

// `include "Cache_struct.sv"

mesi_t currentstate, nextstate, to_update_state;

always_comb
begin
	case(currentstate)
		I:mesi_states_out=I;
		E:mesi_states_out=E;
		S:mesi_states_out=S;
		M:mesi_states_out=M;
		default:mesi_states_out=I;
	endcase
end

always_comb
begin
	case(mesi_states_in)
		I:to_update_state=I;
		E:to_update_state=E;
		S:to_update_state=S;
		M:to_update_state=M;
		default:to_update_state=I;
	endcase
end

//MESI FSM starts
always_ff @(posedge clk or negedge rstb)
	if(!rstb)
	begin
		currentstate <= I;
	end
	else if(valid)
	begin
		currentstate <= to_update_state;
	end
	else
	begin
		currentstate <= nextstate;
		
	end
// make it pulse accurate : FIXME : Adithya
// inclusivity is almost maintained: Check again in test case seperate code not req: Adithya
always_comb
   case(currentstate)
	M : if (nmsg_in == (READ_REQ_L1_D | WRITE_REQ_L1_D))
	    begin
		nextstate = M;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = NULL;
			l2tol1msg_out = SENDLINE;
	    end
	    else if(nmsg_in == SNOOP_READ_REQ)
	    begin
		nextstate   = S;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 1;
			C_out	    = 0; */
			bus_func_out  = WRITE;
			l2tol1msg_out = EVICTLINE; 
	    end
			
	    else if(nmsg_in == SNOOP_READ_WITH_M)
	    begin
		nextstate   = I;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 1;
			C_out	    = 0;*/
			bus_func_out  = WRITE;
			l2tol1msg_out = EVICTLINE; 
	    end
	    
	    else
	    begin
	    	nextstate   = M;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = NULL;
			l2tol1msg_out = NULLMsg;

			
	    end

			

	E : if(nmsg_in == READ_REQ_L1_D)
	    begin
		nextstate = E;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = NULL;
			l2tol1msg_out = SENDLINE;
	    end

	    else if(nmsg_in == WRITE_REQ_L1_D)
	    begin
		nextstate   = M;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = NULL;
			l2tol1msg_out = GETLINE;
	    end
			
	    else if(nmsg_in == SNOOP_READ_REQ)
	    begin
		nextstate   = S;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = NULL;
			l2tol1msg_out = SENDLINE;
	    end
			
	    else if(nmsg_in == SNOOP_READ_WITH_M)
	    begin
		nextstate   = I;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = NULL;
			l2tol1msg_out = INVALIDATELINE;
	    end

	    else
	    begin
	    	nextstate   = E;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = NULL;
			l2tol1msg_out = NULLMsg;
	    end

	S : if(nmsg_in == READ_REQ_L1_D)
	    begin
		nextstate = S;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 1;*/
			bus_func_out  = NULL;
			l2tol1msg_out = SENDLINE;
	    end

	    else if(nmsg_in == WRITE_REQ_L1_D)
	    begin
		nextstate   = M;
			/*BusUpgr_out = 1;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = INVALIDATE;
			l2tol1msg_out = GETLINE;
	    end

	    else if(nmsg_in == READ_REQ_L1_D)
	    begin
		nextstate   = S;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = NULL;
			l2tol1msg_out = SENDLINE;
	    end

	    else if((nmsg_in == SNOOP_READ_WITH_M) | (nmsg_in == SNOOP_INVALID_CMD))
	    begin
		nextstate   = I;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = NULL;
			l2tol1msg_out = INVALIDATELINE;
	    end

	    else
	    begin
	    	nextstate   = S;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = NULL;
			l2tol1msg_out = NULLMsg;

	    end

	I : 	if((nmsg_in == READ_REQ_L1_D) | (nmsg_in == SNOOP_READ_WITH_M) | (nmsg_in == SNOOP_INVALID_CMD))
		begin
			nextstate   = I;
				/*BusUpgr_out = 0;
				BusRd_out   = 0;
				BusRdX_out  = 0;
				Flush	    = 0;
				C_out	    = 0;*/
			bus_func_out  = NULL;
			l2tol1msg_out = INVALIDATELINE;
		end

		else if(nmsg_in == READ_REQ_L1_D)
		begin
			if(C_in)
			begin
			nextstate = S;
				/*BusUpgr_out = 0;
				BusRd_out   = 1;
				BusRdX_out  = 0;
				Flush	    = 0;
				C_out	    = 0;*/
				bus_func_out  = READ;
				l2tol1msg_out = SENDLINE;
			end
			else
			begin
			nextstate = E;
				/*BusUpgr_out = 0;
				BusRd_out   = 1;
				BusRdX_out  = 0;
				Flush	    = 0;
				C_out	    = 0;*/
				bus_func_out  = READ;
				l2tol1msg_out = SENDLINE;
			end
		end

		else if(nmsg_in == WRITE_REQ_L1_D)
		begin
		nextstate   = M;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 1;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = RWIM;
			l2tol1msg_out = GETLINE;
		end

	        else
	        begin
	    	nextstate   = I;
			/*BusUpgr_out = 0;
			BusRd_out   = 0;
			BusRdX_out  = 0;
			Flush	    = 0;
			C_out	    = 0;*/
			bus_func_out  = NULL;
			l2tol1msg_out = NULLMsg;
	        end


	default: nextstate = I;
   endcase

//MESI FSM ends
			
endmodule