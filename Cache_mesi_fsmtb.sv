module Cache_mesi_fsmtb();
logic clk, rstb, PrRd, PrWr, BusUpgr_in, BusRd_in,BusRdX_in, C_in;
logic BusUpgr_out,BusUpgr_out_new, BusRd_out, BusRdX_out, Flush;

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
	PrRd = 0;
	PrWr = 0;
	BusUpgr_in = 0;
	BusRd_in = 0;
	BusRdX_in = 0;
	C_in = 0;
	
	#20;

	PrWr = 1;
	#10
	if(BusRdX_out==1) $display("I to M transition occured");
	PrWr = 0;

	#9
	BusRdX_in = 1;
	#11
	if(Flush==1) $display("M to I transition occured");
	BusRdX_in = 0;

	#9
	PrRd = 1;
	C_in = 1;
	#11
	if(BusRd_out ==1) $display("I to S transition occured");
	PrRd = 0;
	C_in = 0;

	#9
	PrWr = 1;
	#11
	if(BusUpgr_out ==1) $display("S to M transition occured");
	PrWr = 0;

	#9
	PrWr = 1;
	PrRd = 1;
	#11
	$display("M to M transition occured");
	PrWr = 0;
	PrRd = 0;


	#9
	BusRd_in = 1;
	#11
	if(Flush==1) $display("M to S transition occured");
	BusRd_in = 0;

	#9
	BusRd_in = 1;
	#11
	$display("S to S transition occured");
	BusRd_in = 0;

	#9
	BusRdX_in = 1;
	BusUpgr_in = 1;
	#11
	$display("S to I transition occured");
	BusRdX_in = 0;
	BusUpgr_in = 0;

	#9
	BusRd_in = 1;
	BusRdX_in = 1;
	BusUpgr_in = 1;
	#11
	$display("I to I transition occured");
	BusRd_in = 0;
	BusRdX_in = 0;
	BusUpgr_in = 0;

	#9
	PrRd = 1;
	C_in = 0;
	#11
	if(BusRd_out == 1) $display("I to E transition occured");
	PrRd = 0;
	

	#9
	PrRd = 1;
	#11
	$display("E to E transition occured");
	PrRd = 0;

	#9
	BusRdX_in = 1;
	#11
	$display("E to I transition occured");
	BusRdX_in = 0;

	#9
	PrRd = 1;
	C_in = 0;
	#11
	if(BusRd_out == 1) $display("I to E transition occured");
	PrRd = 0;


	#9
	PrWr = 1;
	#11
	$display("E to M transition occured");
	PrWr = 0;
		

#200;
end: clock_reset_gen




endmodule