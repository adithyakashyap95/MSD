module Cache_opr_ctrl (
	input  logic 	clk,
	input  logic 	rstb,
	input  logic 	valid,
	input  logic 	opr_finished,
	output logic 	valid_d,
	output logic    valid_2d,
	output logic 	opr_1,
	output logic 	opr_2,
	output logic    opr_1_pulse,
	output logic    opr_2_pulse
);

logic [8:0]			cntr_opr;  // Counter for operation
logic 				opr_1_d;
logic 				opr_2_d;
logic 				opr_3_d;
logic 				opr_4_d;
logic 				opr_5_d;
logic 				opr_6_d;
logic 				opr_7_d;
logic 				opr_8_d;

// generating valid delayed by 2 cycles
always_ff@(posedge clk or negedge rstb)
begin
	if(rstb==0)
	begin
		valid_d  <= 0;
		valid_2d <= 0;
	end
	else
	begin
		valid_d  <= valid;
		valid_2d <= valid_d;
	end
end

// Generating pulses so that the modules work in series fashion.

always_ff@(posedge clk or negedge rstb)
begin
	if(rstb==0)
	begin
		cntr_opr <= 0;
	end
	else if(opr_finished)
	begin
		cntr_opr <= 0;
	end	
	else if((valid)|(cntr_opr>0))
	begin
		cntr_opr <= cntr_opr + 1;
	end
	else
	begin
		cntr_opr <= cntr_opr;
	end
end

always_ff@(posedge clk or negedge rstb)
begin
	if(rstb==0)
	begin
		opr_1_d <= 0;
		opr_2_d <= 0;
	end
	else
	begin
		opr_1_d <= opr_1;
		opr_2_d <= opr_2;
	end
end

always_comb opr_1_pulse = opr_1 & (~opr_1_d);
always_comb opr_2_pulse = opr_2 & (~opr_2_d);

// FIXME: opr_finished must come from the last operation

always_comb
begin
	if(cntr_opr==0)
	begin
		opr_1 = 0;
		opr_2 = 0;
	end
	else if(cntr_opr>8)
	begin
		opr_1 = 1;
		opr_2 = 1;
	end	
	else if(cntr_opr>4)
	begin
		opr_1 = 1;
		opr_2 = 0;
	end	
	else
	begin
		opr_1 = 0;
		opr_2 = 0;
	end	
end


endmodule
