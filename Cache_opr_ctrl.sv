module Cache_opr_ctrl (
	input  logic 	clk,
	input  logic 	rstb,
	input  logic 	valid,
	input  logic 	opr_finished,
	output logic 	opr_1,
	output logic 	opr_2,
	output logic 	opr_3,
	output logic 	opr_4,
	output logic 	opr_5,
	output logic 	opr_6,
	output logic 	opr_7,
	output logic 	opr_8
);

logic [8:0]			cntr_opr;  // Counter for operation

// Generating pulses so that the modules work in serioes fashion.

always_ff@(posedge clk or negedge rstb)
begin
	if(rstb==0)
	begin
		cntr_opr <= 0;
	end
	else if((valid)|(cntr_opr>0))
	begin
		cntr_opr <= cntr_opr + 1;
	end
	else if(opr_finished)
	begin
		cntr_opr <= 0;
	end
	else
	begin
		cntr_opr <= cntr_opr;
	end
end

// FIXME: opr_finished must come from the last operation

always_comb
begin
	if(cntr_opr==0)
	begin
		opr_1 = 0;
		opr_2 = 0;
		opr_3 = 0;
		opr_4 = 0;
		opr_5 = 0;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end
	else if(cntr_opr>7)
	begin
		opr_1 = 1;
		opr_2 = 0;
		opr_3 = 0;
		opr_4 = 0;
		opr_5 = 0;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end	
	else if(cntr_opr>15)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 0;
		opr_4 = 0;
		opr_5 = 0;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end	
	else if(cntr_opr>23)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 1;
		opr_4 = 0;
		opr_5 = 0;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end	
	else if(cntr_opr>31)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 1;
		opr_4 = 1;
		opr_5 = 0;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end	
	else if(cntr_opr>39)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 1;
		opr_4 = 1;
		opr_5 = 1;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end	
	else if(cntr_opr>47)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 1;
		opr_4 = 1;
		opr_5 = 1;
		opr_6 = 1;
		opr_7 = 0;
		opr_8 = 0;
	end	
	else if(cntr_opr>55)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 1;
		opr_4 = 1;
		opr_5 = 1;
		opr_6 = 1;
		opr_7 = 1;
		opr_8 = 0;
	end	
	else if(cntr_opr>63)
	begin
		opr_1 = 1;
		opr_2 = 1;
		opr_3 = 1;
		opr_4 = 1;
		opr_5 = 1;
		opr_6 = 1;
		opr_7 = 1;
		opr_8 = 1;
	end	
	else
	begin
		opr_1 = 0;
		opr_2 = 0;
		opr_3 = 0;
		opr_4 = 0;
		opr_5 = 0;
		opr_6 = 0;
		opr_7 = 0;
		opr_8 = 0;
	end	
end


endmodule
