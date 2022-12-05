`include "Cache_struct.sv"

module Cache_mesi_fsm(
	input  logic  		clk, 		//clock signal
	input  logic  		rstb, 		//Active low reset signal
	input  logic [1:0] 	C_in,		//An active low input signal when asserted displays
						//that other caches has that cache line

	input  mesi_struct 	mesi_states_in,	//Input signals from cache to MESI logic
	input  logic    	valid,
	input  logic    	valid_d,
	input  n_struct 	nmsg_in,

	//output logic [1:0]   C_out,             //An output signal asserted to display
						  //that the cache has that cache line
	output mesi_struct   	mesi_states_out,  //Input signals from cache to MESI logic after update
	output bus_struct    	bus_func_out,
	output l2tol1_struct 	l2tol1msg_out
);

mesi_t 		currentstate;
mesi_t		nextstate;
mesi_t 		to_update_state;
bus_struct    	nxt_bus_func_out;
l2tol1_struct 	nxt_l2tol1msg_out;

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

// inclusivity is almost maintained: Check again in test case seperate code not req: Adithya

always_comb
   case(currentstate)
	M : if ((nmsg_in == READ_REQ_L1_D) | (nmsg_in == READ_REQ_L1_I))
	    begin
		nextstate         = M;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = SENDLINE;  // Send the line considering the fact that L1 has evicted and L2 is sending the modified data to it
	    end
	    else if ((nmsg_in == WRITE_REQ_L1_D))
	    begin
		nextstate         = M;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = GETLINE;  // Send the line considering the fact that L1 has evicted and L2 is sending the modified data to it
	    end
	    else if(nmsg_in == SNOOP_READ_REQ) // BusRD
	    begin
		nextstate         = S;
		nxt_bus_func_out  = WRITE;      // WRITE to DRAM: FLush
		nxt_l2tol1msg_out = NULLMsg;    // L1 does not need to know this shit
		//C_out 		  = HITM;
	    end
	    else if((nmsg_in == SNOOP_READ_WITH_M) | (nmsg_in == SNOOP_WRITE_REQ)) //BUsRdX
	    begin
		nextstate         = I;
		nxt_bus_func_out  = WRITE;      // WRITE to DRAM: FLsuhing
		nxt_l2tol1msg_out = EVICTLINE;  // Sending msg to L1 to evict the kine to maintain inclusivity 
	    end
	    else
	    begin
	    	nextstate         = M;
		nxt_bus_func_out  = bus_func_out;
		nxt_l2tol1msg_out = l2tol1msg_out;
	    end

	E : if((nmsg_in == READ_REQ_L1_D) | (nmsg_in == READ_REQ_L1_I))
	    begin
		nextstate         = E;
		nxt_bus_func_out  = NULL;      // No Snoop
		nxt_l2tol1msg_out = SENDLINE;  // Send the line to L1 
	    end
	    else if(nmsg_in == WRITE_REQ_L1_D)
	    begin
		nextstate         = M;
		nxt_bus_func_out  = NULL;       // No Snoop: None has it
		nxt_l2tol1msg_out = GETLINE;    // We will send the data 
	    end
	    else if(nmsg_in == SNOOP_READ_REQ) // BUS_RD
	    begin
		nextstate         = S;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = NULLMsg;  // We dont need to send the info
	    end
	    else if((nmsg_in == SNOOP_READ_WITH_M) | (nmsg_in == SNOOP_WRITE_REQ)) // Bus_RD_X
	    begin
		nextstate         = I;
		nxt_bus_func_out  = NULL;            
		nxt_l2tol1msg_out = INVALIDATELINE;   // Invalidate the line
	    end
	    else
	    begin
	    	nextstate         = E;
		nxt_bus_func_out  = bus_func_out;
		nxt_l2tol1msg_out = l2tol1msg_out;
	    end

	S : if((nmsg_in == READ_REQ_L1_D) | (nmsg_in == READ_REQ_L1_I)) //Pr_rd
	    begin
		nextstate         = S; 
		nxt_bus_func_out  = NULL;       
		nxt_l2tol1msg_out = SENDLINE;  // Because L1 is requesting
	    end
	    else if(nmsg_in == WRITE_REQ_L1_D)
	    begin
		nextstate         = M;            
		nxt_bus_func_out  = INVALIDATE;  // Because I am modifying others should invalidate
		nxt_l2tol1msg_out = GETLINE;     // L2 should get modified data from L1
	    end
	    else if((nmsg_in == SNOOP_READ_WITH_M) | (nmsg_in == SNOOP_WRITE_REQ) | (nmsg_in == SNOOP_INVALID_CMD))
	    begin
		nextstate         = I;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = INVALIDATELINE;
	    end
	    else if (nmsg_in == SNOOP_READ_REQ)
	    begin
	    	nextstate         = S;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = NULLMsg;
	    end

	    else
	    begin
	    	nextstate         = S;
		nxt_bus_func_out  = bus_func_out;
		nxt_l2tol1msg_out = l2tol1msg_out;
	    end

	I : if((nmsg_in == SNOOP_READ_REQ) | (nmsg_in == SNOOP_READ_WITH_M) | (nmsg_in == SNOOP_INVALID_CMD))
	    begin
		nextstate         = I;
		nxt_bus_func_out  = NULL;
		nxt_l2tol1msg_out = NULLMsg; // Dont need to send as wen are already invalid state
	    end
	    else if((nmsg_in == READ_REQ_L1_D)| (nmsg_in == READ_REQ_L1_I))
	    begin
		if((C_in==HIT) || (C_in==HITM)) // HIT
		begin
			nextstate         = S;
			nxt_bus_func_out  = READ;      // Snoop read so that other cache should know it to move to diff state
			nxt_l2tol1msg_out = SENDLINE;  // DRAM request should happen 
		end
		else // ((C_in == NOHIT_1)||(C_in == NOHIT_2)) //NOHIT // No HITM in this case as it just read
		begin
			nextstate         = E;
			nxt_bus_func_out  = READ;
			nxt_l2tol1msg_out = SENDLINE;
		end
	    end
	    else if(nmsg_in == WRITE_REQ_L1_D)
	    begin
		nextstate         = M;
		nxt_bus_func_out  = RWIM;      // Upon processor write
		nxt_l2tol1msg_out = SENDLINE;  // Should send the line from L2 to L1 which we got from DRAM
					       // DRAM request
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