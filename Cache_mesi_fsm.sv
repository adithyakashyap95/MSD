`include "Cache_struct.sv"

module Cache_mesi_fsm(
input  logic  clk, 			//clock signal
input  logic  rstb, 			//Active low reset signal
input  logic  C_in,			//An active low input signal when asserted displays
					//that other caches has that cache line

input  mesi_struct mesi_states_in,	//Input signals from cache to MESI logic
input  logic    valid,
input  logic    valid_d,
input  n_struct nmsg_in,

output logic         C_out,             //An output signal asserted to display
					//that the cache has that cache line
output mesi_struct   mesi_states_out,	//Input signals from cache to MESI logic after update

output bus_struct    bus_func_out,
output l2tol1_struct l2tol1msg_out
);

mesi_t currentstate, nextstate, to_update_state;
bus_struct    nxt_bus_func_out;
l2tol1_struct nxt_l2tol1msg_out;

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
	/*else if(valid_d)
	begin
		currentstate <= nextstate;
	end*/
	else
	begin
		currentstate <= nextstate;
	end

// Output to be flopped
always_ff @(posedge clk or negedge rstb)
	if(!rstb)
	begin
		bus_func_out  <= NULL;
		l2tol1msg_out <= NULLMsg;
	end
	else if(valid_d)
	begin
		bus_func_out  <= nxt_bus_func_out;
		l2tol1msg_out <= nxt_l2tol1msg_out;
	end
	else
	begin
		bus_func_out  <= bus_func_out;
		l2tol1msg_out <= l2tol1msg_out;
	end


// make it pulse accurate : FIXME : Adithya
// inclusivity is almost maintained: Check again in test case seperate code not req: Adithya

always_comb
   case(currentstate)
	M : if ((nmsg_in == READ_REQ_L1_D) | (nmsg_in == WRITE_REQ_L1_D))
	    begin
		nextstate         = M;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = SENDLINE;
	    end
	    else if(nmsg_in == SNOOP_READ_REQ)
	    begin
		nextstate         = S;
		nxt_bus_func_out  = WRITE;
		nxt_l2tol1msg_out = EVICTLINE; 
	    end
	    else if(nmsg_in == SNOOP_READ_WITH_M)
	    begin
		nextstate         = I;
		nxt_bus_func_out  = WRITE;
		nxt_l2tol1msg_out = EVICTLINE; 
	    end
	    else
	    begin
	    	nextstate         = M;
		nxt_bus_func_out  = bus_func_out;
		nxt_l2tol1msg_out = l2tol1msg_out;
	    end

	E : if(nmsg_in == READ_REQ_L1_D)
	    begin
		nextstate         = E;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = SENDLINE;
	    end

	    else if(nmsg_in == WRITE_REQ_L1_D)
	    begin
		nextstate         = M;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = GETLINE;
	    end
			
	    else if(nmsg_in == SNOOP_READ_REQ)
	    begin
		nextstate         = S;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = SENDLINE;
	    end
			
	    else if(nmsg_in == SNOOP_READ_WITH_M)
	    begin
		nextstate         = I;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = INVALIDATELINE;
	    end
	    else
	    begin
	    	nextstate         = E;
		nxt_bus_func_out  = bus_func_out;
		nxt_l2tol1msg_out = l2tol1msg_out;
	    end

	S : if(nmsg_in == READ_REQ_L1_D)
	    begin
		nextstate         = S;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = SENDLINE;
	    end

	    else if(nmsg_in == WRITE_REQ_L1_D)
	    begin
		nextstate         = M;
		nxt_bus_func_out  = INVALIDATE;
		nxt_l2tol1msg_out = GETLINE;
	    end

	    else if(nmsg_in == READ_REQ_L1_D)
	    begin
		nextstate         = S;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = SENDLINE;
	    end

	    else if((nmsg_in == SNOOP_READ_WITH_M) | (nmsg_in == SNOOP_INVALID_CMD))
	    begin
		nextstate         = I;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = INVALIDATELINE;
	    end

	    else
	    begin
	    	nextstate         = S;
		nxt_bus_func_out  = bus_func_out;
		nxt_l2tol1msg_out = l2tol1msg_out;

	    end

	I : if((nmsg_in == READ_REQ_L1_D) | (nmsg_in == SNOOP_READ_WITH_M) | (nmsg_in == SNOOP_INVALID_CMD))
	    begin
		nextstate         = I;
			nxt_bus_func_out  = NULL;
			nxt_l2tol1msg_out = INVALIDATELINE;
	    end
	    else if(nmsg_in == READ_REQ_L1_D)
	    begin
		if(C_in)
		begin
			nextstate         = S;
			nxt_bus_func_out  = READ;
			nxt_l2tol1msg_out = SENDLINE;
		end
		else
		begin
			nextstate         = E;
			nxt_bus_func_out  = READ;
			nxt_l2tol1msg_out = SENDLINE;
		end
	    end
	    else if(nmsg_in == WRITE_REQ_L1_D)
	    begin
		nextstate         = M;
		nxt_bus_func_out  = RWIM;
		nxt_l2tol1msg_out = GETLINE;
	    end
	    else
	    begin
	    	nextstate         = I;
		nxt_bus_func_out  = bus_func_out;
		nxt_l2tol1msg_out = l2tol1msg_out;
	    end

   default: begin
		nextstate         = I;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = NULLMsg;
	    end
   endcase

//MESI FSM ends
			
endmodule