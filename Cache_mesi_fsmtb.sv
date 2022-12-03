`include "Cache_struct.sv"
module Cache_mesi_fsmtb();
logic clk, rstb, PrRd, PrWr, BusUpgr_in, BusRd_in,BusRdX_in, C_in;
logic BusUpgr_out,BusUpgr_out_new, BusRd_out, BusRdX_out, Flush;
logic  C_out, mesi_states_out;
logic mesi_states_in, valid;
bus_struct bus_func_out;
l2tol1_struct l2tol1msg_out;
n_struct nmsg_in;

int errorCnt = 0;

// instantiate the FSM
Cache_mesi_fsm DUT(.*);

initial begin: monitor_outputs
    $monitor($time,, "currentstate=%s, nextstate=%s, BusUpgr_out=%b, BusRd_out=%b, BusRdX_out=%b, Flush=%b",
        DUT.Cache_mesi_fsm.currentstate, DUT.Cache_mesi_fsm.nextstate, BusUpgr_out_new, BusRd_out, BusRdX_out, Flush);
end: monitor_outputs

initial begin
    	clk = 0;
        forever #5 clk = ~clk;
end

initial begin: clock_reset_gen
        rstb = 0;
    

	#20 rstb = 1;
	nmsg_in= NULL;
	C_in = 0;
	
	#20;

	nmsg_in = WRITE_REQ_L1_D;
	#10
	if(bus_func_out == WRITE | l2tol1msg_out == EVICTLINE) $display("I to M transition occured");
	/*PrWr = 0;*/
	else
	$display("I to M transition did not occur");

	#9
	nmsg_in = SNOOP_READ_WITH_M;
	#11
	if(bus_func_out == WRITE ) $display("M to I transition occured");
	/*BusRdX_in = 0;*/
	else
	$display("I to M transition did not occur");

	#9
	nmsg_in = READ_REQ_L1_D;
	C_in = 1;
	#11
	if(bus_func_out == READ) $display("I to S transition occured");
	/*PrRd = 0;
	C_in = 0;*/
	else
	$display("I to S transition did not occur");

	#9
	nmsg_in = WRITE_REQ_L1_D;
	#11
	if(bus_func_out == INVALIDATE) $display("S to M transition occured");
	/*PrWr = 0;*/
	else
	$display("S to M transition did not occur");

	#9
	nmsg_in = READ_REQ_L1_D;
	nmsg_in = WRITE_REQ_L1_D;
	/*PrWr = 1;
	PrRd = 1;*/
	#11
	$display("M to M transition occured");
	/*PrWr = 0;
	PrRd = 0;*/


	#9
	nmsg_in = SNOOP_READ_REQ;
	/*BusRd_in = 1;*/
	#11
	if(bus_func_out == WRITE) $display("M to S transition occured");
	/*BusRd_in = 0;*/
	else
	$display("M to S transition did not occur");

	#9
	nmsg_in = SNOOP_READ_REQ;
	#11
	$display("S to S transition occured");
	/*BusRd_in = 0;*/

	#9
	nmsg_in = SNOOP_READ_WITH_M;
	nmsg_in = SNOOP_INVALID_CMD;
	/*BusRdX_in = 1;
	BusUpgr_in = 1;*/
	#11
	$display("S to I transition occured");
	/*BusRdX_in = 0;
	BusUpgr_in = 0;*/

	#9
	nmsg_in = SNOOP_READ_REQ;
	nmsg_in = SNOOP_READ_WITH_M;
	nmsg_in = SNOOP_INVALID_CMD;
	/*BusRd_in = 1;
	BusRdX_in = 1;
	BusUpgr_in = 1;*/
	#11
	$display("I to I transition occured");
	/*BusRd_in = 0;
	BusRdX_in = 0;
	BusUpgr_in = 0;*/

	#9
	nmsg_in = READ_REQ_L1_D;
	/*PrRd = 1*/;
	C_in = 0;
	#11
	if(bus_func_out == READ) $display("I to E transition occured");
	/*PrRd = 0;*/
	

	#9
	nmsg_in = READ_REQ_L1_D;
	/*PrRd = 1;*/
	#11
	$display("E to E transition occured");
	/*PrRd = 0;*/

	#9
	nmsg_in = SNOOP_READ_WITH_M;
	/*BusRdX_in = 1;*/
	#11
	$display("E to I transition occured");
	/*BusRdX_in = 0;*/

	#9
	nmsg_in = READ_REQ_L1_D;
	/*PrRd = 1;*/
	C_in = 0;
	#11
	if(bus_func_out == READ) $display("I to E transition occured");
	/*PrRd = 0;*/
	else
	$display("I to E transition did not occur");


	#9
	nmsg_in = WRITE_REQ_L1_D;
	/*PrWr = 1;*/
	#11
	$display("E to M transition occured");
	/*PrWr = 0;*/
		

#200;
end: clock_reset_gen




endmodule